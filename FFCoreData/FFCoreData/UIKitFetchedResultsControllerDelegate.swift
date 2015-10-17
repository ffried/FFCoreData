//
//  UIKitFetchedResultsControllerDelegate.swift
//  FFCoreData
//
//  Created by Florian Friedrich on 13/06/15.
//  Copyright © 2015 Florian Friedrich. All rights reserved.
//

#if os(iOS)
import UIKit

public class UIKitFetchedResultsControllerDelegate: FetchedResultsControllerDelegate {
    public var preserveSelection = true
    
    internal var selectedIndexPaths = Set<NSIndexPath>()
    
    internal func reapplySelection() {
        let indexPaths = selectedIndexPaths
        selectedIndexPaths.removeAll()
        if preserveSelection { selectIndexPaths(indexPaths.map{$0}) }
    }
    
    internal func selectIndexPaths(indexPaths: [NSIndexPath]) {}
}
#endif
