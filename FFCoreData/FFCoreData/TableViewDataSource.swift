//
//  TableViewDataSource.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 13/06/15.
//  Copyright 2015 Florian Friedrich
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

import Foundation
import UIKit
import CoreData

@objc public protocol TableViewDataSourceDelegate: class, NSObjectProtocol {
    #if swift(>=3.0)
    func tableView(_ tableView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> String
    func tableView(_ tableView: UITableView, configure cell: UITableViewCell, forRowAt indexPath: IndexPath, with object: NSFetchRequestResult?)
    
    // See UITableViewDataSource
    
    @objc optional func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    @objc optional func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    
    @objc(tableView:canEditRowAtIndexPath:)
    optional func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    @objc(tableView:canMoveRowAtIndexPath:)
    optional func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    
    @objc(sectionIndexTitlesForTableView:)
    optional func sectionIndexTitles(for tableView: UITableView) -> [String]?
    @objc(tableView:sectionForSectionIndexTitle:atIndex:)
    optional func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:)
    optional func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    @objc(tableView:moveRowAtIndexPath:toIndexPath:)
    optional func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    #else
    func tableView(tableView: UITableView, cellIdentifierForRowAtIndexPath indexPath: NSIndexPath) -> String
    func tableView(tableView: UITableView, configureCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath, withObject object: NSManagedObject?)
    
    optional func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    optional func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String?
    
    optional func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    optional func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool
    
    optional func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]?
    optional func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
    
    optional func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    optional func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    #endif
}

#if swift(>=3.0)
public final class TableViewDataSource<Result: NSFetchRequestResult>: NSObject, UITableViewDataSource {
    public private(set) weak var tableView: UITableView?
    public private(set) weak var fetchedResultsController: NSFetchedResultsController<Result>?
    
    public weak var delegate: TableViewDataSourceDelegate?
    
    public required init(tableView: UITableView, controller: NSFetchedResultsController<Result>, delegate: TableViewDataSourceDelegate) {
        self.fetchedResultsController = controller
        self.tableView = tableView
        self.delegate = delegate
        super.init()
        self.tableView?.dataSource = self
    }
    
    // MARK: UITableViewDataSource
    @objc(numberOfSectionsInTableView:)
    public func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    @objc public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    @objc(tableView:cellForRowAtIndexPath:)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = delegate?.tableView(tableView, cellIdentifierForRowAt: indexPath) ?? "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let object = fetchedResultsController?.object(at: indexPath)
        delegate?.tableView(tableView, configure: cell, forRowAt: indexPath, with: object)
        return cell
    }
    
    @objc public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let selectorToCheck = #selector(TableViewDataSourceDelegate.tableView(_:titleForHeaderInSection:))
        if let delegate = delegate, delegate.responds(to: selectorToCheck) {
            return delegate.tableView?(tableView, titleForHeaderInSection: section)
        }
        if let count = fetchedResultsController?.sections?.count, count > 0 {
            return fetchedResultsController?.sections?[section].name
        }
        return nil
    }
    
    @objc public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return delegate?.tableView?(tableView, titleForFooterInSection: section)
    }
    
    @objc(sectionIndexTitlesForTableView:)
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return delegate?.sectionIndexTitles?(for: tableView) ?? fetchedResultsController?.sectionIndexTitles
    }
    
    @objc(tableView:sectionForSectionIndexTitle:atIndex:)
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return delegate?.tableView?(tableView, sectionForSectionIndexTitle: title, at: index)
            ?? fetchedResultsController?.section(forSectionIndexTitle: title, at: index)
            ?? 0
    }
    
    @objc(tableView:canEditRowAtIndexPath:)
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return delegate?.tableView?(tableView, canEditRowAt: indexPath) ?? true
    }
    
    @objc(tableView:canMoveRowAtIndexPath:)
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let selectorToCheck = #selector(TableViewDataSourceDelegate.tableView(_:moveRowAt:to:))
        return delegate?.tableView?(tableView, canMoveRowAt: indexPath) ?? delegate?.responds(to: selectorToCheck) ?? false
    }
    
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:)
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        delegate?.tableView?(tableView, commit: editingStyle, forRowAt: indexPath)
    }
    
    @objc(tableView:moveRowAtIndexPath:toIndexPath:)
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        delegate?.tableView?(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
    }
}
#else
public final class TableViewDataSource: NSObject, UITableViewDataSource {
    public private(set) weak var tableView: UITableView?
    public private(set) weak var fetchedResultsController: NSFetchedResultsController?
    
    public weak var delegate: TableViewDataSourceDelegate?
    
    public required init(tableView: UITableView, controller: NSFetchedResultsController, delegate: TableViewDataSourceDelegate) {
        self.fetchedResultsController = controller
        self.tableView = tableView
        self.delegate = delegate
        super.init()
        self.tableView?.dataSource = self
    }
    
    // MARK: UITableViewDataSource
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = delegate?.tableView(tableView, cellIdentifierForRowAtIndexPath: indexPath) ?? "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let object = fetchedResultsController?.objectAtIndexPath(indexPath) as? NSManagedObject
        delegate?.tableView(tableView, configureCell: cell, forRowAtIndexPath: indexPath, withObject: object)
        return cell
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        #if swift(>=2.2)
            let selectorToCheck = #selector(TableViewDataSourceDelegate.tableView(_:titleForHeaderInSection:))
        #else
    let selectorToCheck: Selector = "tableView:titleForHeaderInSection:"
        #endif
        if let delegate = delegate where delegate.respondsToSelector(selectorToCheck) {
            return delegate.tableView?(tableView, titleForHeaderInSection: section)
        }
        if fetchedResultsController?.sections?.count > 0 {
            return fetchedResultsController?.sections?[section].name
        }
        return nil
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return delegate?.tableView?(tableView, titleForFooterInSection: section)
    }
    
    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return delegate?.sectionIndexTitlesForTableView?(tableView) ?? fetchedResultsController?.sectionIndexTitles
    }
    
    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return delegate?.tableView?(tableView, sectionForSectionIndexTitle: title, atIndex: index) ??
            fetchedResultsController?.sectionForSectionIndexTitle(title, atIndex: index) ?? 0
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return delegate?.tableView?(tableView, canEditRowAtIndexPath: indexPath) ?? true
    }
    
    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        #if swift(>=2.2)
            let selectorToCheck = #selector(TableViewDataSourceDelegate.tableView(_:moveRowAtIndexPath:toIndexPath:))
        #else
            let selectorToCheck: Selector = "tableView:moveRowAtIndexPath:toIndexPath:"
        #endif
        return delegate?.tableView?(tableView, canMoveRowAtIndexPath: indexPath) ?? delegate?.respondsToSelector(selectorToCheck) ?? false
    }
    
    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.tableView?(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        delegate?.tableView?(tableView, moveRowAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    }
}
#endif
