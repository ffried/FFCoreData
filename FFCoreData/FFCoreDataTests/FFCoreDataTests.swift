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
        let bundle = NSBundle(forClass: self.dynamicType)
        let sqliteName = "TestData"
        let modelName = "TestModel"
        CoreDataStack.configuration = CoreDataStack.Configuration(bundle: bundle, modelName: modelName, sqliteName: sqliteName)
        return CoreDataStack.MainContext
        }()
    let testUUID = "c1b45162-12b4-11e5-8a0d-10ddb1c330b4"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
//        context = CoreDataStack.createTemporaryMainContext()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        CoreDataStack.saveContext(context)
        super.tearDown()
    }
    
    func testContextCreation() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertNotNil(context, "Main context shouldn't be nil!")
    }
    
    func testObjectCreation() {
        let obj = TestEntity.createObjectInManagedObjectContext(context)
        obj.uuid = NSUUID().UUIDString
        XCTAssertNotNil(obj, "Created object must not be nil!")
        context.deleteObject(obj)
    }
    
    func testSearchObject() {
        
        do {
            let obj = try TestEntity.findOrCreateObjectByKeyObjectDictionary(["uuid": testUUID], inManagedObjectContext: context)
            XCTAssertEqual(obj.uuid, testUUID, "UUIDs of found or created object and search params must be the same!")
            context.deleteObject(obj)
        } catch {
            XCTFail("Find or create must not fail: \(error)")
        }
    }
    
    private func createTempObjects(count: Int, _ context: NSManagedObjectContext) throws {
        for _ in 0..<count {
            let uuid = NSUUID().UUIDString
            try TestEntity.findOrCreateObjectByKeyObjectDictionary(["uuid": uuid], inManagedObjectContext: context)
        }
    }
    
    func testSearchObjects() {
        do {
            let count = 100
            try createTempObjects(count, context)
            let objects = try TestEntity.allObjectsInContext(context) as? [TestEntity]
            XCTAssertNotNil(objects, "Found objects must not be nil!")
            XCTAssertGreaterThanOrEqual(objects!.count, count, "Count of found objects must be greater than or equal to the created objects")
            objects?.forEach(context.deleteObject)
        } catch {
            XCTFail("Find must not fail: \(error)")
        }
    }
    
    func testParentStore() {
        let mainCtx = CoreDataStack.MainContext
        let tempCtx = CoreDataStack.createTemporaryBackgroundContext()
        do {
            let count = 100
            try createTempObjects(count, tempCtx)
            CoreDataStack.saveContext(tempCtx)
            let objects = try TestEntity.allObjectsInContext(context) as? [TestEntity]
            XCTAssertNotNil(objects, "Found objects must not be nil!")
            XCTAssertGreaterThanOrEqual(objects!.count, count, "Count of found objects must be greater than or equal to the created objects")
            objects?.map(mainCtx.deleteObject)
            CoreDataStack.saveContext(tempCtx)
        } catch {
            XCTFail("Find must not fail: \(error)")
        }
    }
}
