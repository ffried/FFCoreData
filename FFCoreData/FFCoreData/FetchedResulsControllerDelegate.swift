//
//  FetchedResulsControllerDelegate.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 11/06/15.
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

import class Foundation.NSObject
import struct Foundation.IndexPath
import protocol CoreData.NSFetchRequestResult
import protocol CoreData.NSFetchedResultsControllerDelegate
import protocol CoreData.NSFetchedResultsSectionInfo
import enum CoreData.NSFetchedResultsChangeType
import class CoreData.NSFetchedResultsController

@objc public protocol FetchedResultsControllerManagerDelegate: NSFetchedResultsControllerDelegate {}

@available(OSX 10.12, *)
public class FetchedResultsControllerManager<Result: NSFetchRequestResult>: NSObject, NSFetchedResultsControllerDelegate {
    
    public typealias Controller = NSFetchedResultsController<Result>
    public typealias Delegate = FetchedResultsControllerManagerDelegate
    
    public private(set) final weak var fetchedResultsController: Controller?
    public final weak var delegate: Delegate?
    
    internal init(fetchedResultsController: Controller, delegate: Delegate?) {
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        super.init()
        self.fetchedResultsController?.delegate = self
    }
    
    // MARK: - Internal functions
    internal func beginUpdates() {}
    
    internal func insertSection(at index: Int) {}
    internal func removeSection(at index: Int) {}
    internal func updateSection(at index: Int) {}
    internal func moveSection(from oldIndex: Int, to newIndex: Int) {}
    
    internal func insertSubobject(at indexPath: IndexPath) {}
    internal func removeSubobject(at indexPath: IndexPath) {}
    internal func updateSubobject(at indexPath: IndexPath) {}
    internal func moveSubobject(from oldIndexPath: IndexPath, to newIndexPath: IndexPath) {}
    
    internal func endUpdates() {}
    
    // MARK: - NSFetchedResultsControllerDelegate
    @objc public dynamic func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerWillChangeContent?(controller)
        beginUpdates()
    }
    
    @objc(controller:didChangeSection:atIndex:forChangeType:)
    public dynamic func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertSection(at: sectionIndex)
        case .update:
            updateSection(at: sectionIndex)
        case .delete:
            removeSection(at: sectionIndex)
        default:
            print("FFCoreData: Unsupported change type: \(type)")
        }
        delegate?.controller?(controller, didChange: sectionInfo, atSectionIndex: sectionIndex, for: type)
    }
    
    @objc(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)
    public dynamic func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertSubobject(at: newIndexPath!)
        case .update:
            updateSubobject(at: indexPath!)
        case .delete:
            removeSubobject(at: indexPath!)
        case .move:
            moveSubobject(from: indexPath!, to: newIndexPath!)
        }
        delegate?.controller?(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
    }
    
    @objc public dynamic func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        endUpdates()
        delegate?.controllerDidChangeContent?(controller)
    }
    
    @objc public dynamic func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return delegate?.controller?(controller, sectionIndexTitleForSectionName: sectionName) ?? controller.sectionIndexTitle(forSectionName: sectionName)
    }
}
