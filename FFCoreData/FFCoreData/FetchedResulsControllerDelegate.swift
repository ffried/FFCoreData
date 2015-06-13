//
//  FetchedResulsControllerDelegate.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 11/06/15.
//  Copyright © 2015 Florian Friedrich. All rights reserved.
//

import FFCoreData

public protocol FetchedResultsControllerDelegateDelegate: NSFetchedResultsControllerDelegate {}

public class FetchedResultsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
    
    public let fetchedResultsController: NSFetchedResultsController
    public weak var delegate: FetchedResultsControllerDelegateDelegate?
    
    public required init(fetchedResultsController: NSFetchedResultsController, delegate: FetchedResultsControllerDelegateDelegate? = nil) {
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        super.init()
        self.fetchedResultsController.delegate = self
    }
    
    // MARK: - Internal functions
    internal func beginUpdates() {}
    
    internal func insertSectionAtIndex(index: Int) {}
    internal func removeSectionAtIndex(index: Int) {}
    internal func updateSectionAtIndex(index: Int) {}
    internal func moveSectionFromIndex(fromIndex: Int, toIndex: Int) {}
    
    internal func insertSubobjectAtIndexPath(index: NSIndexPath) {}
    internal func removeSubobjectAtIndexPath(index: NSIndexPath) {}
    internal func updateSubobjectAtIndexPath(index: NSIndexPath) {}
    internal func moveSubobjectFromIndexPath(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {}
    
    internal func endUpdates() {}
    
    // MARK: - NSFetchedResultsControllerDelegate
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        delegate?.controllerWillChangeContent?(controller)
        beginUpdates()
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            insertSectionAtIndex(sectionIndex)
        case .Update:
            updateSectionAtIndex(sectionIndex)
        case .Delete:
            removeSectionAtIndex(sectionIndex)
        default:
            print("Unsupported change type: \(type)")
        }
        delegate?.controller?(controller, didChangeSection: sectionInfo, atIndex: sectionIndex, forChangeType: type)
    }

    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
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
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        endUpdates()
        delegate?.controllerDidChangeContent?(controller)
    }
    
    public func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return delegate?.controller?(controller, sectionIndexTitleForSectionName: sectionName) ?? controller.sectionIndexTitleForSectionName(sectionName)
    }

}
