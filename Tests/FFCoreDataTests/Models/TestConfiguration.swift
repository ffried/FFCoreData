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
    private static let testModelName = "TestModel"
    private static let testOptions: Options = [.default, .clearDataStoreOnSetupFailure]
    // We need to use random names to make sure the files do not interfere with eachother.
    private static var testSQLiteName: String { UUID().uuidString }

    private static let modelURL = Bundle.module.url(forResource: testModelName, withExtension: "momd")!

    static var test: CoreDataStack.Configuration {
        #if os(iOS) || os(watchOS) || os(tvOS)
        return CoreDataStack.Configuration(modelURL: modelURL, sqliteName: testSQLiteName, options: testOptions)
        #else
        return CoreDataStack.Configuration(modelURL: modelURL, applicationSupportSubfolder: "FFCoreDataTests", sqliteName: testSQLiteName, options: testOptions)
        #endif
    }
}
