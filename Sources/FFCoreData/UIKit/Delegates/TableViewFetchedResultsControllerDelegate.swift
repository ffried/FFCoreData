//
//  TableViewFetchedResultsControllerDelegate.swift
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
import struct Foundation.IndexSet
import struct Foundation.IndexPath
import protocol CoreData.NSFetchRequestResult
import class CoreData.NSFetchedResultsController
import enum UIKit.UITableViewRowAnimation
import class UIKit.UITableView

public final class TableViewFetchedResultsControllerManager<Result: NSFetchRequestResult>: UIKitFetchedResultsControllerManager<Result> {
    public private(set) weak var tableView: UITableView?

    public var animation: UITableView.RowAnimation = .automatic

    public required init(fetchedResultsController: Controller, tableView: UITableView, delegate: (any Delegate)? = nil) {
        self.tableView = tableView
        super.init(fetchedResultsController: fetchedResultsController, delegate: delegate)
    }

    // MARK: - Begin / End Updates
    override func beginUpdates() {
        super.beginUpdates()
        tableView?.beginUpdates()
        reapplySelection()
    }

    override func endUpdates() {
        super.endUpdates()
        tableView?.endUpdates()
    }

    // MARK: - Selection
    override func select(indexPaths: Set<IndexPath>) {
        super.select(indexPaths: indexPaths)
        indexPaths.forEach { tableView?.selectRow(at: $0, animated: false, scrollPosition: .none) }
    }

    // MARK: - Sections
    override func insertSection(at index: Int) {
        super.insertSection(at: index)
        tableView?.insertSections(IndexSet(integer: index), with: animation)
    }

    override func updateSection(at index: Int) {
        super.updateSection(at: index)
        tableView?.reloadSections(IndexSet(integer: index), with: animation)
    }

    override func removeSection(at index: Int) {
        super.removeSection(at: index)
        tableView?.deleteSections(IndexSet(integer: index), with: animation)
    }

    override func moveSection(from oldIndex: Int, to newIndex: Int) {
        super.moveSection(from: oldIndex, to: newIndex)
        tableView?.moveSection(oldIndex, toSection: newIndex)
    }

    // MARK: - Rows
    override func insertSubobject(at indexPath: IndexPath) {
        super.insertSubobject(at: indexPath)
        tableView?.insertRows(at: [indexPath], with: animation)
    }

    override func updateSubobject(at indexPath: IndexPath) {
        super.updateSubobject(at: indexPath)
        let selected = tableView?.indexPathsForSelectedRows?.contains(indexPath)
        tableView?.reloadRows(at: [indexPath], with: animation)
        if selected == true { selectedIndexPaths.insert(indexPath) }
    }

    override func removeSubobject(at indexPath: IndexPath) {
        super.removeSubobject(at: indexPath)
        tableView?.deleteRows(at: [indexPath], with: animation)
    }

    override func moveSubobject(from oldIndexPath: IndexPath, to newIndexPath: IndexPath) {
        super.moveSubobject(from: oldIndexPath, to: newIndexPath)
        tableView?.moveRow(at: oldIndexPath, to: newIndexPath)
    }
}
#endif
