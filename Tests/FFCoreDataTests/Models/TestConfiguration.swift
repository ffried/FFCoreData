//
//  TestConfiguration.swift
//  FFCoreDataTests
//
//  Created by Florian Friedrich on 01.06.18.
//  Copyright © 2018 Florian Friedrich. All rights reserved.
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import FFCoreData

#if !Xcode
fileprivate extension Pipe {
    func readString() throws -> String {
        let data: Data?
        if #available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *) {
            data = try fileHandleForReading.readToEnd()
        } else {
            data = fileHandleForReading.readDataToEndOfFile()
        }
        return data.map { String(decoding: $0, as: UTF8.self) }?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            ?? ""
    }
}

fileprivate extension Process {
    typealias Output = (stdout: String, stderr: String)

    struct ExecutionFailure: Error, CustomStringConvertible {
        let exitCode: Int32
        let output: Output

        var description: String {
            "Execution failed \(exitCode):\n\(output.stderr)"
        }
    }

    static func run(executablePath: String, arguments: [String]) throws -> Output {
        let (stdout, stderr) = (Pipe(), Pipe())
        let p = Process()
        p.executableURL = URL(fileURLWithPath: executablePath)
        p.arguments = arguments
        p.standardOutput = stdout
        p.standardError = stderr
        try p.run()
        p.waitUntilExit()
        let output: Output = try (stdout.readString(), stderr.readString())
        if case let exitCode = p.terminationStatus, exitCode != 0 {
            throw ExecutionFailure(exitCode: exitCode, output: output)
        }
        return output
    }

    static func xcrun(arguments: [String]) throws -> Output {
        try run(executablePath: "/usr/bin/xcrun", arguments: arguments)
    }
}
#endif

extension CoreDataStack.Configuration {
    private static let testModelName = "TestModel"
    private static let testOptions: Options = [.default, .clearDataStoreOnSetupFailure]
    // We need to use random names to make sure the files do not interfere with eachother.
    private static var testSQLiteName: String { UUID().uuidString }

    private static let modelURL: URL = {
        if let resURL = Bundle.module.url(forResource: testModelName, withExtension: "momd") {
            return resURL
        }
        #if Xcode
        fatalError("Could not find \(testModelName).momd in \(Bundle.module.bundlePath)")
        #else
        guard let folder = Bundle.module.url(forResource: testModelName, withExtension: "xcdatamodeld") else {
            fatalError("Could not find \(testModelName).xcdatamodeld in \(Bundle.module.bundlePath)")
        }
        let modelURL = folder.deletingLastPathComponent()
            .appendingPathExtension(testModelName)
            .appendingPathExtension("momd")
        if FileManager.default.fileExists(at: modelURL) { return modelURL }
        do {
            let sdkPath = try Process.xcrun(arguments: ["--sdk", "macosx", "--show-sdk-path"]).stdout
            _ = try Process.xcrun(arguments: ["momc",
                                              "--sdkroot", sdkPath,
                                              "--macosx-deployment-target", "10.12",
                                              "--module", "FFCoreDataTests",
                                              folder.path,
                                              modelURL.deletingLastPathComponent().path,
            ])
        } catch {
            fatalError("Could not compile model: \(error)")
        }
        if let url = Bundle.module.url(forResource: testModelName, withExtension: "momd") { return url }
        // Bundle sometimes caches resource lookup results.
        if FileManager.default.fileExists(at: modelURL) { return modelURL }
        fatalError("Model compilation seems to have failed. Could not find \(testModelName).momd in \(Bundle.module.bundlePath)")
        #endif
    }()

    static var test: CoreDataStack.Configuration {
        #if os(iOS) || os(watchOS) || os(tvOS)
        return CoreDataStack.Configuration(modelURL: modelURL, sqliteName: testSQLiteName, options: testOptions)
        #else
        return CoreDataStack.Configuration(modelURL: modelURL, applicationSupportSubfolder: "FFCoreDataTests", sqliteName: testSQLiteName, options: testOptions)
        #endif
    }
}
