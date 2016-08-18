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

import Foundation
import UIKit
import CoreData

#if swift(>=3.0)
public final class TableViewFetchedResultsControllerManager<Result: NSFetchRequestResult>: UIKitFetchedResultsControllerManager<Result> {
    public private(set) weak var tableView: UITableView?
    
    public var animation = UITableViewRowAnimation.automatic
    
    public required init(fetchedResultsController: Controller, tableView: UITableView, delegate: FetchedResultsControllerManagerDelegate? = nil) {
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
    override func select(indexPaths: [IndexPath]) {
        super.select(indexPaths: indexPaths)
        indexPaths.forEach { self.tableView?.selectRow(at: $0, animated: false, scrollPosition: .none) }
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
        if let s = selected, s { selectedIndexPaths.insert(indexPath) }
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
#else
public class TableViewFetchedResultsControllerManager: UIKitFetchedResultsControllerManager {
    public private(set) weak var tableView: UITableView?
    
    public var animation = UITableViewRowAnimation.Automatic
    
    public required init(fetchedResultsController: NSFetchedResultsController, tableView: UITableView, delegate: FetchedResultsControllerDelegateDelegate? = nil) {
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
    override func selectIndexPaths(indexPaths: [NSIndexPath]) {
        super.selectIndexPaths(indexPaths)
        indexPaths.forEach { self.tableView?.selectRowAtIndexPath($0, animated: false, scrollPosition: .None) }
    }
    
    // MARK: - Sections
    override func insertSectionAtIndex(index: Int) {
        super.insertSectionAtIndex(index)
        tableView?.insertSections(NSIndexSet(index: index), withRowAnimation: animation)
    }
    
    override func updateSectionAtIndex(index: Int) {
        super.updateSectionAtIndex(index)
        tableView?.reloadSections(NSIndexSet(index: index), withRowAnimation: animation)
    }
    
    override func removeSectionAtIndex(index: Int) {
        super.removeSectionAtIndex(index)
        tableView?.deleteSections(NSIndexSet(index: index), withRowAnimation: animation)
    }
    
    override func moveSectionFromIndex(fromIndex: Int, toIndex: Int) {
        super.moveSectionFromIndex(fromIndex, toIndex: toIndex)
        tableView?.moveSection(fromIndex, toSection: toIndex)
    }
    
    // MARK: - Rows
    override func insertSubobjectAtIndexPath(indexPath: NSIndexPath) {
        super.insertSubobjectAtIndexPath(indexPath)
        tableView?.insertRowsAtIndexPaths([indexPath], withRowAnimation: animation)
    }
    
    override func updateSubobjectAtIndexPath(indexPath: NSIndexPath) {
        super.updateSubobjectAtIndexPath(indexPath)
        let selected = tableView?.indexPathsForSelectedRows?.contains(indexPath)
        tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: animation)
        if let s = selected where s == true { selectedIndexPaths.insert(indexPath) }
    }
    
    override func removeSubobjectAtIndexPath(indexPath: NSIndexPath) {
        super.removeSubobjectAtIndexPath(indexPath)
        tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: animation)
    }
    
    override func moveSubobjectFromIndexPath(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        super.moveSubobjectFromIndexPath(fromIndexPath, toIndexPath: toIndexPath)
        tableView?.moveRowAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
    }
}
#endif
