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

#if canImport(UIKit) && !os(watchOS)
#if canImport(ObjectiveC)
import ObjectiveC
#endif
import protocol Foundation.NSObjectProtocol
import class Foundation.NSObject
import struct Foundation.IndexPath
import let Foundation.NSNotFound
import enum UIKit.UITableViewCellEditingStyle
import protocol UIKit.UITableViewDataSource
import class UIKit.UITableView
import class UIKit.UITableViewCell
import protocol CoreData.NSFetchRequestResult
import class CoreData.NSFetchedResultsController

@objc public protocol TableViewDataSourceDelegate: NSObjectProtocol {
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
    optional func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    @objc(tableView:moveRowAtIndexPath:toIndexPath:)
    optional func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

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
    public dynamic func numberOfSections(in tableView: UITableView) -> Int {
        fetchedResultsController?.sections?.count ?? 0
    }
    
    @objc public dynamic func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    @objc(tableView:cellForRowAtIndexPath:)
    public dynamic func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = delegate?.tableView(tableView, cellIdentifierForRowAt: indexPath) ?? "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let object = fetchedResultsController?.object(at: indexPath)
        delegate?.tableView(tableView, configure: cell, forRowAt: indexPath, with: object)
        return cell
    }
    
    @objc public dynamic func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let selectorToCheck = #selector(TableViewDataSourceDelegate.tableView(_:titleForHeaderInSection:))
        if let delegate = delegate, delegate.responds(to: selectorToCheck) {
            return delegate.tableView?(tableView, titleForHeaderInSection: section)
        }
        if let count = fetchedResultsController?.sections?.count, count > 0 {
            return fetchedResultsController?.sections?[section].name
        }
        return nil
    }
    
    @objc public dynamic func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        delegate?.tableView?(tableView, titleForFooterInSection: section)
    }
    
    @objc(sectionIndexTitlesForTableView:)
    public dynamic func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        delegate?.sectionIndexTitles?(for: tableView) ?? fetchedResultsController?.sectionIndexTitles
    }
    
    @objc(tableView:sectionForSectionIndexTitle:atIndex:)
    public dynamic func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return delegate?.tableView?(tableView, sectionForSectionIndexTitle: title, at: index)
            ?? fetchedResultsController?.section(forSectionIndexTitle: title, at: index)
            ?? NSNotFound
    }
    
    @objc(tableView:canEditRowAtIndexPath:)
    public dynamic func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        delegate?.tableView?(tableView, canEditRowAt: indexPath) ?? true
    }
    
    @objc(tableView:canMoveRowAtIndexPath:)
    public dynamic func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let selectorToCheck = #selector(TableViewDataSourceDelegate.tableView(_:moveRowAt:to:))
        return delegate?.tableView?(tableView, canMoveRowAt: indexPath) ?? delegate?.responds(to: selectorToCheck) ?? false
    }

    @objc(tableView:commitEditingStyle:forRowAtIndexPath:)
    public dynamic func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        delegate?.tableView?(tableView, commit: editingStyle, forRowAt: indexPath)
    }
    
    @objc(tableView:moveRowAtIndexPath:toIndexPath:)
    public dynamic func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        delegate?.tableView?(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
    }
}
#endif
