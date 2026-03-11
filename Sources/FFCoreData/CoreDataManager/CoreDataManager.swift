//
//  CoreDataManager.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 10/06/15.
//  Copyright 2015 Florian Friedrich
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
public import CoreData
import FFFoundation
#if canImport(os)
import os
#endif

fileprivate final class CoreDataManager {
    private lazy var managedObjectModel = NSManagedObjectModel(contentsOf: configuration.modelURL)!

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = configuration.databaseURL
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true,
            ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            guard configuration.clearDataStoreOnSetupFailure else {
#if compiler(>=6.2)
                unsafe os_log("Failed to add persistent store with error: %@", log: .ffCoreData, type: .fault, String(describing: error))
#else
                os_log("Failed to add persistent store with error: %@", log: .ffCoreData, type: .fault, String(describing: error))
#endif
                fatalError("FFCoreData: Failed to add persistent store with error: \(error)")
            }
#if compiler(>=6.2)
            unsafe os_log("Failed to add persistent store with error: %@\nTrying to delete the data store now!",
                          log: .ffCoreData, type: .error, String(describing: error))
#else
            os_log("Failed to add persistent store with error: %@\nTrying to delete the data store now!",
                   log: .ffCoreData, type: .error, String(describing: error))
#endif
            do {
                try clearDataStore()
            } catch {
#if compiler(>=6.2)
                unsafe os_log("Failed to delete data store with error: %@!", log: .ffCoreData, type: .error, String(describing: error))
#else
                os_log("Failed to delete data store with error: %@!", log: .ffCoreData, type: .error, String(describing: error))
#endif
            }
            do {
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            } catch {
#if compiler(>=6.2)
                unsafe os_log("Failed to add persistent store with error: %@", log: .ffCoreData, type: .fault, String(describing: error))
#else
                os_log("Failed to add persistent store with error: %@", log: .ffCoreData, type: .fault, String(describing: error))
#endif
                fatalError("FFCoreData: Failed to add persistent store with error: \(error)")
            }
        }
        return coordinator
    }()

    private lazy var backgroundSavingContext: NSManagedObjectContext = {
        let ctx: NSManagedObjectContext
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            ctx = NSManagedObjectContext(.privateQueue)
        } else {
            ctx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        }
        ctx.persistentStoreCoordinator = persistentStoreCoordinator
        ctx.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return ctx
    }()

    private(set) lazy var mainQueueContext: NSManagedObjectContext = {
        let ctx: NSManagedObjectContext
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            ctx = NSManagedObjectContext(.mainQueue)
        } else {
            ctx = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
        ctx.parent = backgroundSavingContext
        return ctx
    }()

    let configuration: CoreDataStack.Configuration
    init(configuration: CoreDataStack.Configuration) {
        self.configuration = configuration
    }

    private func configureTemporaryContext(_ context: NSManagedObjectContext) {
        context.parent = mainQueueContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        context.undoManager = nil
    }

    func createTemporaryMainContext() -> NSManagedObjectContext {
        let ctx: NSManagedObjectContext
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            ctx = NSManagedObjectContext(.mainQueue)
        } else {
            ctx = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
        configureTemporaryContext(ctx)
        return ctx
    }

    func createTemporaryBackgroundContext() -> NSManagedObjectContext {
        let ctx: NSManagedObjectContext
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            ctx = NSManagedObjectContext(.privateQueue)
        } else {
            ctx = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        }
        configureTemporaryContext(ctx)
        return ctx
    }


    func clearDataStore() throws {
        let fileManager = FileManager.default
        try fileManager.contentsOfDirectory(at: configuration.storePath, includingPropertiesForKeys: nil, options: [])
            .lazy
            .filter { [configuration] in $0.lastPathComponent.hasPrefix(configuration.sqliteName) }
            .forEach(fileManager.removeItem)
    }
}

fileprivate extension NSManagedObjectContext {
    func _save(rollbackOnError: Bool) -> Bool {
        guard hasChanges else { return true }
        do {
            try save()
            return true
        } catch {
#if compiler(>=6.2)
            unsafe os_log("Unresolved error while saving NSManagedObjectContext: %@", log: .ffCoreData, type: .error, String(describing: error))
#else
            os_log("Unresolved error while saving NSManagedObjectContext: %@", log: .ffCoreData, type: .error, String(describing: error))
#endif
            if rollbackOnError {
#if compiler(>=6.2)
                unsafe os_log("Rolling back changes...", log: .ffCoreData, type: .info)
#else
                os_log("Rolling back changes...", log: .ffCoreData, type: .info)
#endif
                rollback()
            }
            return false
        }
    }
}

@frozen
public enum CoreDataStack {
    private static let _storage: Synchronized<CoreDataManager?> = .init()

    private static var manager: CoreDataManager {
        _storage.wrappedValue ?? _storage.withValue {
            if let existing = $0 { return existing }
            let newManager = CoreDataManager(configuration: .legacyConfiguration)
            $0 = newManager
            return newManager
        }
    }

    public static var configuration: Configuration {
        get { _storage.wrappedValue?.configuration ?? .legacyConfiguration }
        set {
            NSManagedObject.shouldRemoveNamespaceInEntityName.exchange(with: newValue.removeNamespacesFromEntityNames)
            _storage.withValueVoid {
                guard $0?.configuration != newValue else { return }
                $0 = .init(configuration: newValue)
            }
        }
    }

    public static var mainContext: NSManagedObjectContext { manager.mainQueueContext }

    @preconcurrency
    public static func save(context: NSManagedObjectContext, rollback: Bool = true, completion: @escaping @Sendable (Bool) -> () = { _ in }) {
        context.perform {
            guard context._save(rollbackOnError: rollback) else { return completion(false) }
            guard let parent = context.parent else { return completion(true) }
            save(context: parent, rollback: rollback, completion: {
                if !$0 && rollback {
                    context.perform {
                        context.rollback()
                        completion(false)
                    }
                } else {
                    completion(true)
                }
            })
        }
    }

    public static func saveMainContext(rollback: Bool = true, completion: @escaping @Sendable (Bool) -> () = { _ in }) {
        save(context: mainContext, rollback: rollback, completion: completion)
    }

    @discardableResult
    @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public static func saveContext(_ context: NSManagedObjectContext, rollback: Bool = true) async -> Bool {
        if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
            guard await context.perform({ context._save(rollbackOnError: rollback) }) else { return false }
        } else {
            guard await context.run({ context._save(rollbackOnError: rollback) }) else { return false }
        }
        guard let parent = context.parent else { return true }
        let success = await saveContext(parent, rollback: rollback)
        if !success && rollback {
            await context.run { $0.rollback() }
        }
        return success
    }

    @discardableResult
    @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public static func saveMainContext(rollback: Bool = true) async -> Bool {
        await saveContext(mainContext, rollback: rollback)
    }

    public static func createTemporaryMainContext() -> NSManagedObjectContext {
        manager.createTemporaryMainContext()
    }

    public static func createTemporaryBackgroundContext() -> NSManagedObjectContext {
        manager.createTemporaryBackgroundContext()
    }

    public static func clearDataStore() throws {
        try manager.clearDataStore()
    }

    public static func closeConnections() {
        _storage.withValue {
            guard let manager = $0 else { return }
            $0 = .init(configuration: manager.configuration)
        }
    }
}

extension CoreDataStack {
    public struct Configuration: Equatable, Sendable {
        fileprivate static let legacyConfiguration: Configuration = {
            let bundle = Bundle.main
            let modelName = bundle.infoDictionary?["FFCDDataManagerModelName"] as? String
            let sqliteName = bundle.infoDictionary?["FFCDDataManagerSQLiteName"] as? String
            return Configuration(bundle: bundle, modelName: modelName, sqliteName: sqliteName)
        }()

        public struct Options: OptionSet, Sendable {
            public typealias RawValue = UInt

            public let rawValue: RawValue

            public init(rawValue: RawValue) { self.rawValue = rawValue }
        }

        public let modelURL: URL
        public let sqliteName: String
        public let storePath: URL

        private var sqliteStoreName: String { sqliteName + ".sqlite" }
        public var databaseURL: URL { storePath.appendingPathComponent(sqliteStoreName) }

#if os(macOS)
        public let applicationSupportSubfolderName: String
#endif

        public let options: Options
        @inlinable
        public var removeNamespacesFromEntityNames: Bool { options.contains(.removeNamespacesFromEntityNames) }
        @inlinable
        public var clearDataStoreOnSetupFailure: Bool { options.contains(.clearDataStoreOnSetupFailure) }

        private static func url(for searchPathDirectory: FileManager.SearchPathDirectory, subDirectoryName: String? = nil) -> URL {
            let fileManager = FileManager.default
            var dataDirectory = fileManager.urls(for: searchPathDirectory, in: .userDomainMask)[0]
            if let subfolderName = subDirectoryName {
                dataDirectory.appendPathComponent(subfolderName)
            }
            do {
                try fileManager.createDirectoryIfNeeded(at: dataDirectory)
            } catch {
#if compiler(>=6.2)
                unsafe os_log("Could not create data folder: %@", log: .ffCoreData, type: .error, String(describing: error))
#else
                os_log("Could not create data folder: %@", log: .ffCoreData, type: .error, String(describing: error))
#endif
            }
            return dataDirectory
        }
#if os(iOS) || os(watchOS) || os(tvOS)
        public static let appDataDirectoryURL: URL = url(for: .documentDirectory)
#elseif os(macOS)
        public static func appDataDirectoryURL(withSubfolderName subfolderName: String) -> URL {
            url(for: .applicationSupportDirectory, subDirectoryName: subfolderName)
        }
#endif

        private static let infoDictionaryTargetDisplayNameKey = "CFBundleDisplayName"
        private static let infoDictionaryTargetNameKey = String(kCFBundleNameKey)
        private static let defaultTargetName = "UNKNOWN_TARGET_NAME"

        private init(modelURL: URL,
                     sqliteName: String,
                     storePath: URL?,
                     appSupportFolderName: @autoclosure () -> String,
                     options: Options) {
            self.modelURL = modelURL
            self.sqliteName = sqliteName
            self.options = options

#if os(iOS) || os(watchOS) || os(tvOS)
            self.storePath = storePath ?? Configuration.appDataDirectoryURL
#elseif os(macOS)
            let folderName = appSupportFolderName()
            self.applicationSupportSubfolderName = folderName
            self.storePath = storePath ?? Configuration.appDataDirectoryURL(withSubfolderName: folderName)
#endif
        }

        private init(bundle: Bundle,
                     modelName: String?,
                     sqliteName: String?,
                     storePath: URL?,
                     appSupportFolderName: String?,
                     options: Options) {
            func targetName(from bundle: Bundle) -> String {
                guard let infoDict = bundle.infoDictionary else { return Configuration.defaultTargetName }
                let name = infoDict[Configuration.infoDictionaryTargetDisplayNameKey] ?? infoDict[Configuration.infoDictionaryTargetNameKey]
                return (name as? String) ?? Configuration.defaultTargetName
            }

            self.init(modelURL: bundle.url(forResource: modelName ?? targetName(from: bundle), withExtension: "momd")!,
                      sqliteName: sqliteName ?? targetName(from: bundle),
                      storePath: storePath,
                      appSupportFolderName: appSupportFolderName ?? bundle.bundleIdentifier ?? targetName(from: bundle),
                      options: options)
        }

#if os(iOS) || os(watchOS) || os(tvOS)
        public init(bundle: Bundle,
                    storePath: URL? = nil,
                    modelName: String? = nil,
                    sqliteName: String? = nil,
                    options: Options = .default) {
            self.init(bundle: bundle,
                      modelName: modelName,
                      sqliteName: sqliteName,
                      storePath: storePath,
                      appSupportFolderName: nil,
                      options: options)
        }

        public init(modelURL: URL,
                    storePath: URL? = nil,
                    sqliteName: String,
                    options: Options = .default) {
            self.init(modelURL: modelURL,
                      sqliteName: sqliteName,
                      storePath: storePath,
                      appSupportFolderName: "",
                      options: options)
        }
#elseif os(macOS)
        public init(bundle: Bundle,
                    applicationSupportSubfolder: String? = nil,
                    storePath: URL? = nil,
                    modelName: String? = nil,
                    sqliteName: String? = nil,
                    options: Options = .default) {
            self.init(bundle: bundle,
                      modelName: modelName,
                      sqliteName: sqliteName,
                      storePath: storePath,
                      appSupportFolderName: applicationSupportSubfolder,
                      options: options)
        }

        public init(modelURL: URL,
                    applicationSupportSubfolder: String,
                    storePath: URL? = nil,
                    sqliteName: String,
                    options: Options = .default) {
            self.init(modelURL: modelURL,
                      sqliteName: sqliteName,
                      storePath: storePath,
                      appSupportFolderName: applicationSupportSubfolder,
                      options: options)
        }
#endif
    }
}

extension CoreDataStack.Configuration.Options {
    public static var `default`: CoreDataStack.Configuration.Options { .removeNamespacesFromEntityNames }

    public static let removeNamespacesFromEntityNames = CoreDataStack.Configuration.Options(rawValue: 1 << 0)
    public static let clearDataStoreOnSetupFailure = CoreDataStack.Configuration.Options(rawValue: 1 << 1)
}
