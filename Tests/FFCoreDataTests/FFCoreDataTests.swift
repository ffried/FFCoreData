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

import XCTest
import CoreData
import FFFoundation
import FFCoreData

final class FFCoreDataTests: XCTestCase {
    var context: NSManagedObjectContext!
    let testUUID = "c1b45162-12b4-11e5-8a0d-10ddb1c330b4"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        CoreDataStack.configuration = .test
        context = CoreDataStack.mainContext
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        context = nil
        // Resets the manager
        CoreDataStack.configuration = CoreDataStack.configuration
        XCTAssertNoThrow(try CoreDataStack.clearDataStore())
        super.tearDown()
    }
    
    private func createTempObjects<UUIDs>(for uuids: UUIDs, in context: NSManagedObjectContext) throws
    where UUIDs: Sequence, UUIDs.Element == String
    {
        for uuid in uuids {
            _ = try TestEntity.findOrCreate(in: context, by: [#keyPath(TestEntity.uuid): uuid])
        }
    }
    
    private func createTempObjects<UUIDs>(for uuids: UUIDs, in context: NSManagedObjectContext) throws
    where UUIDs: Sequence, UUIDs.Element == UUID
    {
        try createTempObjects(for: uuids.lazy.map(\.uuidString), in: context)
    }
    
    private func createTempObjects(amount count: Int, in context: NSManagedObjectContext) throws {
        try createTempObjects(for: (0..<count).lazy.map { _ in UUID() }, in: context)
    }
    
    func testContextCreation() {
        XCTAssertNotNil(context)
    }
    
    func testObjectCreation() {
        XCTAssertNoThrow(try TestEntity.create(in: context))
    }
    
    func testObjectCreationWithDictionary() throws {
        let uuid = UUID().uuidString
        let obj = try TestEntity.create(in: context, applying: [#keyPath(TestEntity.uuid): uuid])
        XCTAssertEqual(obj.uuid, uuid)
    }
    
    func testObjectCreationWithDictionaryExpression() throws {
        let uuid = UUID().uuidString
        let obj = try TestEntity.create(in: context, setting: \.uuid == uuid)
        XCTAssertEqual(obj.uuid, uuid)
    }
    
    func testSearchObject() throws {
        let obj = try TestEntity.findOrCreate(in: context, by: [#keyPath(TestEntity.uuid): testUUID])
        XCTAssertEqual(obj.uuid, testUUID)
    }
    
    func testSearchObjectWithDictionaryExpression() throws {
        let obj = try TestEntity.findOrCreate(in: context, where: \.uuid == testUUID)
        XCTAssertEqual(obj.uuid, testUUID)
    }
    
    func testFindObjectWithEqualExpression() throws {
        let uuids = [UUID(), UUID()]
        try createTempObjects(for: uuids, in: context)
        let equalObjects = try TestEntity.find(in: context, where: \.uuid == uuids[0].uuidString)
        let notEqualObjects = try TestEntity.find(in: context, where: \.uuid != uuids[0].uuidString)
        XCTAssertEqual(equalObjects.count, 1)
        XCTAssertEqual(equalObjects.first?.uuid, uuids[0].uuidString)
        XCTAssertEqual(notEqualObjects.count, 1)
        XCTAssertEqual(notEqualObjects.first?.uuid, uuids[1].uuidString)
    }
    
    func testFindObjectWithComparisonExpression() throws {
        let uuids = ["A", "B", "C", "D"]
        try createTempObjects(for: uuids, in: context)
        let greaterObjects = try TestEntity.find(in: context, where: \.uuid > uuids[1], sortedBy: ^\.uuid)
        let smallerObjects = try TestEntity.find(in: context, where: \.uuid <= uuids[1], sortedBy: ^\.uuid)
        XCTAssertEqual(greaterObjects.count, 2)
        XCTAssertEqual(greaterObjects.map(\.uuid), Array(uuids[2...]))
        XCTAssertEqual(smallerObjects.count, 2)
        XCTAssertEqual(smallerObjects.map(\.uuid), Array(uuids[..<2]))
    }
    
    func testSearchObjects() throws {
        let count = 100
        try createTempObjects(amount: count, in: context)
        let objects = try TestEntity.all(in: context)
        XCTAssertEqual(objects.count, count)
    }
    
    func testParentStore() throws {
        let tempCtx = CoreDataStack.createTemporaryBackgroundContext()
        let count = 100
        try createTempObjects(amount: count, in: tempCtx)
        let expect = expectation(description: "Waiting for save to complete")
        CoreDataStack.save(context: tempCtx) {
            XCTAssertTrue($0)
            expect.fulfill()
        }
        waitForExpectations(timeout: 3, handler: { XCTAssertNil($0) })
        let objects = try TestEntity.all(in: context)
        XCTAssertEqual(objects.count, count)
    }
}
