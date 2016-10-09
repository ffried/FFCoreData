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
import FFCoreData

class FFCoreDataTests: XCTestCase {

    lazy var context: NSManagedObjectContext = {
        let bundle = Bundle(for: type(of: self))
        let sqliteName = "TestData"
        let modelName = "TestModel"
        CoreDataStack.configuration = CoreDataStack.Configuration(bundle: bundle, modelName: modelName, sqliteName: sqliteName)
        return CoreDataStack.mainContext
        }()
    let testUUID = "c1b45162-12b4-11e5-8a0d-10ddb1c330b4"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
//        context = CoreDataStack.createTemporaryMainContext()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        CoreDataStack.save(context: context)
        super.tearDown()
    }
    
    func testContextCreation() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertNotNil(context, "Main context shouldn't be nil!")
    }
    
    func testObjectCreation() {
        let obj = TestEntity.createObject(in: context)
        obj.uuid = UUID().uuidString
        XCTAssertNotNil(obj, "Created object must not be nil!")
        context.delete(obj)
    }
    
    func testSearchObject() {
        do {
            let obj = try TestEntity.findOrCreateObject(byKeyObjectDictionary: ["uuid": testUUID], in: context)
            XCTAssertEqual(obj.uuid, testUUID, "UUIDs of found or created object and search params must be the same!")
            context.delete(obj)
        } catch {
            XCTFail("Find or create must not fail: \(error)")
        }
    }
    
    private func createTempObjects(amount count: Int, in context: NSManagedObjectContext) throws {
        for _ in 0..<count {
            let uuid = UUID().uuidString
            try TestEntity.findOrCreateObject(byKeyObjectDictionary: ["uuid": uuid], in: context)
        }
    }
    
    func testSearchObjects() {
        do {
            let count = 100
            try createTempObjects(amount: count, in: context)
            let objects = try TestEntity.allObjects(in: context) as? [TestEntity]
            XCTAssertNotNil(objects, "Found objects must not be nil!")
            XCTAssertGreaterThanOrEqual(objects!.count, count, "Count of found objects must be greater than or equal to the created objects")
            objects?.forEach(context.delete)
        } catch {
            XCTFail("Find must not fail: \(error)")
        }
    }
    
    func testParentStore() {
        let mainCtx = CoreDataStack.mainContext
        let tempCtx = CoreDataStack.createTemporaryBackgroundContext()
        do {
            let count = 100
            try createTempObjects(amount: count, in: tempCtx)
            CoreDataStack.save(context: tempCtx)
            let objects = try TestEntity.allObjects(in: context) as? [TestEntity]
            XCTAssertNotNil(objects, "Found objects must not be nil!")
            XCTAssertGreaterThanOrEqual(objects!.count, count, "Count of found objects must be greater than or equal to the created objects")
            objects?.forEach(mainCtx.delete)
            CoreDataStack.save(context: tempCtx)
        } catch {
            XCTFail("Find must not fail: \(error)")
        }
    }
}
