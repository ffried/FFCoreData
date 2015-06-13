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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let bundle = NSBundle(forClass: self.dynamicType)
        CoreDataStack.configuration = CoreDataStack.Configuration(bundle: bundle)
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
        XCTAssertNotNil(obj, "Created object must not be nil!")
    }
}
