//
//  FetchedResulsControllerDelegate.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 11/06/15.
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
import CoreData

public protocol FetchedResultsControllerDelegateDelegate: NSFetchedResultsControllerDelegate {}

public class FetchedResultsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
    
    public private(set) final weak var fetchedResultsController: NSFetchedResultsController?
    public final weak var delegate: FetchedResultsControllerDelegateDelegate?
    
    internal init(fetchedResultsController: NSFetchedResultsController, delegate: FetchedResultsControllerDelegateDelegate?) {
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        super.init()
        self.fetchedResultsController?.delegate = self
    }
    
    // MARK: - Internal functions
    internal func beginUpdates() {}
    
    internal func insertSectionAtIndex(index: Int) {}
    internal func removeSectionAtIndex(index: Int) {}
    internal func updateSectionAtIndex(index: Int) {}
    internal func moveSectionFromIndex(fromIndex: Int, toIndex: Int) {}
    
    internal func insertSubobjectAtIndexPath(indexPath: NSIndexPath) {}
    internal func removeSubobjectAtIndexPath(indexPath: NSIndexPath) {}
    internal func updateSubobjectAtIndexPath(indexPath: NSIndexPath) {}
    internal func moveSubobjectFromIndexPath(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {}
    
    internal func endUpdates() {}
    
    // MARK: - NSFetchedResultsControllerDelegate
    public final func controllerWillChangeContent(controller: NSFetchedResultsController) {
        delegate?.controllerWillChangeContent?(controller)
        beginUpdates()
    }
    
    public final func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            insertSectionAtIndex(sectionIndex)
        case .Update:
            updateSectionAtIndex(sectionIndex)
        case .Delete:
            removeSectionAtIndex(sectionIndex)
        default:
            print("FFCoreData: Unsupported change type: \(type)")
        }
        delegate?.controller?(controller, didChangeSection: sectionInfo, atIndex: sectionIndex, forChangeType: type)
    }

    public final func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            insertSubobjectAtIndexPath(newIndexPath!)
        case .Update:
            updateSubobjectAtIndexPath(indexPath!)
        case .Delete:
            removeSubobjectAtIndexPath(indexPath!)
        case .Move:
            moveSubobjectFromIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
        delegate?.controller?(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
    }
    
    public final func controllerDidChangeContent(controller: NSFetchedResultsController) {
        endUpdates()
        delegate?.controllerDidChangeContent?(controller)
    }
    
    public final func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return delegate?.controller?(controller, sectionIndexTitleForSectionName: sectionName) ?? controller.sectionIndexTitleForSectionName(sectionName)
    }
}
