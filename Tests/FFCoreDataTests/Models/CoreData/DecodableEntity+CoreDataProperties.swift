//
//  DecodableEntity+CoreDataProperties.swift
//  FFCoreDataTests
//
//  Created by Florian Friedrich on 10.10.19.
//  Copyright © 2019 Florian Friedrich. All rights reserved.
//
//

import Foundation
import CoreData


extension DecodableEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DecodableEntity> {
        return NSFetchRequest<DecodableEntity>(entityName: "DecodableEntity")
    }

    @NSManaged public var counter: Int32
    @NSManaged public var identifier: String?
    @NSManaged public var isTested: Bool
    @NSManaged public var name: String?

}
