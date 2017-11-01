//
//  AccordionTableTableViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/22/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

/**
 This class is used for accordion effect in `UITableViewController`.
 Just subclass it and implement `tableView:heightForRowAtIndexPath:`
 (based on information in `expandedIndexPaths` property).
 */
open class AccordionTableViewController: UITableViewController {
    
    // MARK: Properties
    open var expandedIndexPaths = [IndexPath]()
    open var shouldAnimateCellToggle = true
    open var shouldScrollIfNeededAfterCellExpand = true
    
  
    open func toggleCell(_ cell: AccordionTableViewCell, animated: Bool) {
        self.toggleCellState(expand: !cell.expanded, cell, animated: animated)
    }
    
    // MARK: UITableViewDelegate
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AccordionTableViewCell {
            toggleCell(cell, animated: shouldAnimateCellToggle)
        }
    }
    
    // We must call this action in tableView:cellForRowAtIndexPath
    open func setExpandfor(cell: AccordionTableViewCell, indexPath: IndexPath) {
        let expanded = expandedIndexPaths.contains(indexPath)
        cell.setExpanded(expanded, animated: false)
    }
    
    // MARK: Helpers
    private func toggleCellState(expand:Bool, _ cell: AccordionTableViewCell, animated: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            if !animated {
                self.manageExpandedIndexPaths(add: expand, indexPath: indexPath)
                tableView.reloadData()
            } else {
                CATransaction.begin()
                CATransaction.setCompletionBlock({ () -> Void in
                    // 2. animate views after expanding
                    self.tableView.beginUpdates()
                    self.manageExpandedIndexPaths(add: expand, indexPath: indexPath)
                    self.tableView.endUpdates()
                })
                
                cell.setExpanded(expand, animated: true)
                CATransaction.commit()
            }
        }
    }
    
    private func manageExpandedIndexPaths(add: Bool, indexPath: IndexPath) {
        if add {
            expandedIndexPaths.append(indexPath)
        } else if let index = expandedIndexPaths.index(of: indexPath) {
            expandedIndexPaths.remove(at: index)
        }
    }
    
    func addInto(viewController: UIViewController, containerView: UIView) {
        viewController.addChildViewController(self)
        containerView.addSubview(self.view)
        self.view.bindFrameToSuperviewBounds()
        self.didMove(toParentViewController: viewController)
    }
}
