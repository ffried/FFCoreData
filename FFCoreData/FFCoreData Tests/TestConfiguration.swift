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

import FFCoreData

extension CoreDataStack.Configuration {
    private final class BundleClass {}
    static var test: CoreDataStack.Configuration {
        return CoreDataStack.Configuration(bundle: Bundle(for: BundleClass.self), modelName: "TestModel", sqliteName: "TestData")
    }
}
