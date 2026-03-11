//
//  FFCoreDataTests.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 13/06/15.
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

import Testing
import CoreData
import FFFoundation
import FFCoreData

@Suite
final class FFCoreDataTests {
    let context: NSManagedObjectContext
    let testUUID = "c1b45162-12b4-11e5-8a0d-10ddb1c330b4"
    
    init() {
        CoreDataStack.configuration = .test
        context = CoreDataStack.mainContext
    }

    deinit {
        CoreDataStack.closeConnections()
        do {
            try CoreDataStack.clearDataStore()
        } catch {
            Issue.record(error)
        }
    }
    
    private func createTempObjects(for uuids: some Sequence<String>, in context: NSManagedObjectContext) throws {
        for uuid in uuids {
            _ = try TestEntity.findOrCreate(in: context, where: \TestEntity.uuid == uuid)
        }
    }
    
    private func createTempObjects(for uuids: some Sequence<UUID>, in context: NSManagedObjectContext) throws {
        try createTempObjects(for: uuids.lazy.map(\.uuidString), in: context)
    }
    
    private func createTempObjects(amount count: Int, in context: NSManagedObjectContext) throws {
        try createTempObjects(for: (0..<count).lazy.map { _ in UUID() }, in: context)
    }

    @Test
    func objectCreation() throws {
        _ = try TestEntity.create(in: context)
    }

    @Test
    func objectCreationWithDictionary() throws {
        let uuid = UUID().uuidString
        let obj = try TestEntity.create(in: context, applying: [#keyPath(TestEntity.uuid): uuid])
        #expect(obj.uuid == uuid)
    }

    @Test
    func objectCreationWithDictionaryExpression() throws {
        let uuid = UUID().uuidString
        let obj = try TestEntity.create(in: context, setting: \.uuid == uuid)
        #expect(obj.uuid == uuid)
    }

    @Test
    func searchObject() throws {
        let obj = try TestEntity.findOrCreate(in: context, by: [#keyPath(TestEntity.uuid): testUUID])
        #expect(obj.uuid == testUUID)
    }

    @Test
    func searchObjectWithDictionaryExpression() throws {
        let obj = try TestEntity.findOrCreate(in: context, where: \.uuid == testUUID)
        #expect(obj.uuid == testUUID)
    }

    @Test
    func findObjectWithEqualExpression() throws {
        let uuids = [UUID(), UUID()]
        try createTempObjects(for: uuids, in: context)
        let equalObjects = try TestEntity.find(in: context, where: \.uuid == uuids[0].uuidString)
        let notEqualObjects = try TestEntity.find(in: context, where: \.uuid != uuids[0].uuidString)
        #expect(equalObjects.count == 1)
        #expect(equalObjects.first?.uuid == uuids[0].uuidString)
        #expect(notEqualObjects.count == 1)
        #expect(notEqualObjects.first?.uuid == uuids[1].uuidString)
    }

    @Test
    func findObjectWithComparisonExpression() throws {
        let uuids = ["A", "B", "C", "D"]
        try createTempObjects(for: uuids, in: context)
        let greaterObjects = try TestEntity.find(in: context, where: \.uuid > uuids[1], sortedBy: ^\.uuid)
        let smallerObjects = try TestEntity.find(in: context, where: \.uuid <= uuids[1], sortedBy: ^\.uuid)
        #expect(greaterObjects.count == 2)
        #expect(greaterObjects.map(\.uuid) == Array(uuids[2...]))
        #expect(smallerObjects.count == 2)
        #expect(smallerObjects.map(\.uuid) == Array(uuids[..<2]))
    }

    @Test
    func searchObjects() throws {
        let count = 100
        try createTempObjects(amount: count, in: context)
        let objects = try TestEntity.all(in: context)
        #expect(objects.count == count)
    }

    @Test
    func parentStore() async throws {
        let tempCtx = CoreDataStack.createTemporaryBackgroundContext()
        let count = 100
        try createTempObjects(amount: count, in: tempCtx)
        #expect(await CoreDataStack.saveContext(tempCtx))
        let objects = try TestEntity.all(in: context)
        #expect(objects.count == count)
    }
}
