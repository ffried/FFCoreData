//
//  TestEntity+CoreDataProperties.swift
//  FFCoreDataTests
//
//  Created by Florian Friedrich on 10.10.19.
//  Copyright © 2019 Florian Friedrich. All rights reserved.
//
//

import Foundation
import CoreData


extension TestEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TestEntity> {
        return NSFetchRequest<TestEntity>(entityName: "TestEntity")
    }

    @NSManaged public var uuid: String?

}
