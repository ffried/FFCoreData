//
//  NSFetchedResultsPublisher.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 09.07.19.
//  Copyright © 2019 Florian Friedrich. All rights reserved.
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

import Combine
import CoreData

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension NSFetchedResultsController {
    public struct Publisher: Combine.Publisher {
        public typealias Output = Array<ResultType>
        public typealias Failure = Error

        private let delegate: PublisherControllerDelegate<ResultType>

        public var fetchRequest: NSFetchRequest<ResultType> { delegate.controller.fetchRequest }
        public var context: NSManagedObjectContext { delegate.controller.managedObjectContext }

        public init(fetchRequest: NSFetchRequest<ResultType>, context: NSManagedObjectContext) {
            delegate = .init(fetchRequest: fetchRequest, context: context)
        }

        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            delegate.subject.receive(subscriber: subscriber)
            delegate.fetchIfNeeded()
        }
    }

    /*
    // TODO: Re-enable once it compiles.
    public static func publish(changesFor fetchRequest: NSFetchRequest<ResultType>, in context: NSManagedObjectContext) -> Publisher {
        return Publisher(fetchRequest: fetchRequest, context: context)
    }
    */
}

// This class could theoretically be nested, but currently this does not compile.
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
fileprivate final class PublisherControllerDelegate<ResultType: NSFetchRequestResult>: NSObject, NSFetchedResultsControllerDelegate {
    let controller: NSFetchedResultsController<ResultType>
    let subject: PassthroughSubject<Array<ResultType>, Error> = .init()

    private var didFetch = false

    init(fetchRequest: NSFetchRequest<ResultType>, context: NSManagedObjectContext) {
        self.controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        super.init()
    }

    func fetch() {
        do {
            try controller.performFetch()
            controller.fetchedObjects.map(send)
        } catch {
            subject.send(completion: .failure(error))
        }
    }

    func fetchIfNeeded() {
        guard !didFetch else { return }
        didFetch = true
        fetch()
    }

    private func send(from objects: [NSFetchRequestResult]) {
        (objects as? [ResultType]).map(subject.send)
    }

    @objc dynamic func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        controller.fetchedObjects.map(send)
    }
}
