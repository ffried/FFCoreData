//
//  FFCoreDataTests.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 13/06/15.
//  Copyright © 2015 Florian Friedrich. All rights reserved.
//

import XCTest
import FFCoreData

class FFCoreDataTests: XCTestCase {
    
    lazy var context: NSManagedObjectContext = CoreDataStack.MainContext
    lazy var testUUID: String = "c1b45162-12b4-11e5-8a0d-10ddb1c330b4"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let bundle = NSBundle(forClass: self.dynamicType)
        let sqliteName = "TestData"
        let modelName = "TestModel"
        CoreDataStack.configuration = CoreDataStack.Configuration(bundle: bundle, modelName: modelName, sqliteName: sqliteName)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testContextCreation() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertNotNil(context, "Main context shouldn't be nil!")
    }
    
    func testObjectCreation() {
        let obj = TestEntity.createInManagedObjectContext(context)
        obj.uuid = NSUUID().UUIDString
        XCTAssertNotNil(obj, "Created object must not be nil!")
    }
    
    func testSearchObject() {
        do {
            let obj = try TestEntity.findOrCreateObjectInManagedObjectContext(context, byKeyObjectDictionary: ["uuid": testUUID]) as? TestEntity
            XCTAssertNotNil(obj, "Found or created object must not be nil!")
            XCTAssertEqual(obj!.uuid!, testUUID, "UUIDs of found object and search params must be the same!")
        } catch {
            XCTAssert(false, "Find or create must not fail: \(error)")
        }
    }
}
