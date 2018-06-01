//
//  CoreDataDecodableTests.swift
//  FFCoreDataTests
//
//  Created by Florian Friedrich on 01.06.18.
//  Copyright © 2018 Florian Friedrich. All rights reserved.
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
import FFCoreData

final class DecodableEntity: NSManagedObject, FindOrCreatable, CoreDataDecodable {
    struct DTO: Codable {
        let idenfitier: String
        let name: String?
        let isTested: Bool
        let counter: Int32
    }

    func update(from dto: DTO) throws {
        identifier = dto.idenfitier
        name = dto.name
        isTested = dto.isTested
        counter = dto.counter
    }
}

final class CoreDataDecodableTests: XCTestCase {

    var context: NSManagedObjectContext!

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

    private func generateTestJSON(count: Int) throws -> Data {
        func randInt(_ val: Int) -> Int { return Int(arc4random_uniform(.init(val))) }
        func randBool(_ val: Int) -> Bool { return randInt(val) % 2 == 0 }
        let dtos = (1...count).map {
            DecodableEntity.DTO(idenfitier: "ID_\($0)",
                name: randBool($0) ? nil : "Test_\($0)",
                isTested: randBool($0),
                counter: .init(randInt($0)))
        }
        return try JSONEncoder().encode(dtos)
    }

    func testConcurrentDecoding() throws {
        let parallelRuns = 50
        let testDataCount = 10_000

        let testObjects: [(data: Data, ctx: NSManagedObjectContext)] = try (0..<parallelRuns).map { _ in
            try (generateTestJSON(count: testDataCount),
                 CoreDataStack.createTemporaryBackgroundContext())
        }
        var failures: [Error?] = Array(repeating: nil, count: parallelRuns)
        DispatchQueue.concurrentPerform(iterations: parallelRuns) {
            do {
                try testObjects[$0].ctx.asDecodingContext { [data = testObjects[$0].data] in
                    _ = try JSONDecoder().decode([DecodableEntity].self, from: data)
                }
            } catch {
                failures[$0] = error
            }
        }
        for run in 0..<parallelRuns {
            XCTAssertNil(failures[run], "Run \(run) failed!")
        }
        for (idx, data) in testObjects.enumerated() {
            XCTAssertEqual(try DecodableEntity.all(in: data.ctx).count, testDataCount, "Context at \(idx) did not have enough objects!")
        }
    }
}
