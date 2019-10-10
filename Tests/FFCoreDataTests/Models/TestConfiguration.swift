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

extension CoreDataStack.Configuration {
    #if SWIFT_PACKAGE
    static let test: CoreDataStack.Configuration = {
        var modelURL = URL(fileURLWithPath: #file)
        modelURL.deleteLastPathComponent() // Models
        modelURL.appendPathComponent("TestModel")
        modelURL.appendPathExtension("momd")
        #if os(iOS) || os(watchOS) || os(tvOS)
        return CoreDataStack.Configuration(modelURL: modelURL, sqliteName: "TestData")
        #else
        return CoreDataStack.Configuration(modelURL: modelURL, applicationSupportSubfolder: "FFCoreDataTests", sqliteName: "TestData")
        #endif
    }()
    #else
    private final class BundleClass {}
    static let test = CoreDataStack.Configuration(bundle: Bundle(for: BundleClass.self), modelName: "TestModel", sqliteName: "TestData")
    #endif
}
