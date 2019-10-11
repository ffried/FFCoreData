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
import FFFoundation
import FFCoreData

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
        let dtos = (1...count).map {
            DecodableEntity.DTO(idenfitier: "ID_\($0)",
                name: Bool.random() ? nil : "Test_\($0)",
                isTested: .random(),
                counter: .random(in: 0..<Int32($0)))
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
        let failures: Atomic<[Error?]> = Atomic(wrappedValue: Array(repeating: nil, count: parallelRuns))
        DispatchQueue.concurrentPerform(iterations: parallelRuns) { iteration in
            do {
                try testObjects[iteration].ctx.asDecodingContext { [data = testObjects[iteration].data] in
                    _ = try JSONDecoder().decode([DecodableEntity].self, from: data)
                }
            } catch {
                failures.withValueVoid { $0[iteration] = error }
            }
        }
        let allFailures = failures.wrappedValue
        for run in 0..<parallelRuns {
            XCTAssertNil(allFailures[run], "Run \(run) failed!")
        }
        for (idx, data) in testObjects.enumerated() {
            XCTAssertEqual(try DecodableEntity.all(in: data.ctx).count, testDataCount, "Context at \(idx) did not have enough objects!")
        }
    }
}
