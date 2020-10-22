//
//  DecodableEntity+CoreDataClass.swift
//  FFCoreDataTests
//
//  Created by Florian Friedrich on 10.10.19.
//  Copyright © 2019 Florian Friedrich. All rights reserved.
//
//

import Foundation
import CoreData
import FFCoreData

@objc(DecodableEntity)
public final class DecodableEntity: NSManagedObject, FindOrCreatable, CoreDataDecodable {
    public struct DTO: Codable {
        let idenfitier: String
        let name: String?
        let isTested: Bool
        let counter: Int32
    }

    public func update(from dto: DTO) throws {
        identifier = dto.idenfitier
        name = dto.name
        isTested = dto.isTested
        counter = dto.counter
    }
}
