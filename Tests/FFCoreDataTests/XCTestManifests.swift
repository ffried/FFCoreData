#if !canImport(ObjectiveC)
import XCTest

extension CoreDataDecodableTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__CoreDataDecodableTests = [
        ("testConcurrentDecoding", testConcurrentDecoding),
    ]
}

extension FFCoreDataTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__FFCoreDataTests = [
        ("testContextCreation", testContextCreation),
        ("testObjectCreation", testObjectCreation),
        ("testObjectCreationWithDictionary", testObjectCreationWithDictionary),
        ("testParentStore", testParentStore),
        ("testSearchObject", testSearchObject),
        ("testSearchObjects", testSearchObjects),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CoreDataDecodableTests.__allTests__CoreDataDecodableTests),
        testCase(FFCoreDataTests.__allTests__FFCoreDataTests),
    ]
}
#endif