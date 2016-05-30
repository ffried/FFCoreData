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

#if os(iOS)
import Foundation
import UIKit
import CoreData

@objc public protocol TableViewDataSourceDelegate: class, NSObjectProtocol {
    func tableView(tableView: UITableView, cellIdentifierForRowAtIndexPath indexPath: NSIndexPath) -> String
    func tableView(tableView: UITableView, configureCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath, withObject object: NSManagedObject?)
    
    // See UITableViewDataSource
    optional func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    optional func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String?
    
    optional func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    optional func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool
    
    optional func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]?
    optional func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
    
    optional func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    optional func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
}

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
            let selectorToCheck = "tableView:titleForHeaderInSection"
        #endif
        if let delegate = delegate where delegate.respondsToSelector(selectorToCheck) {
            return delegate.tableView?(tableView, titleForHeaderInSection: section)
        }
        if fetchedResultsController?.sections?.count > 0 {
            return fetchedResultsController?.sections?[section].name
        }
        return nil
    }
    
    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return delegate?.tableView?(tableView, sectionForSectionIndexTitle: title, atIndex: index) ??
            fetchedResultsController?.sectionForSectionIndexTitle(title, atIndex: index) ?? 0
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return delegate?.tableView?(tableView, titleForFooterInSection: section)
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return delegate?.tableView?(tableView, canEditRowAtIndexPath: indexPath) ?? true
    }
    
    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        #if swift(>=2.2)
            let selectorToCheck = #selector(TableViewDataSourceDelegate.tableView(_:moveRowAtIndexPath:toIndexPath:))
        #else
            let selectorToCheck = "tableView:moveRowAtIndexPath:toIndexPath:"
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
