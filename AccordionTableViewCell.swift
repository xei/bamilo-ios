//
//  AccordionTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/22/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit


open class AccordionTableViewCell: BaseTableViewCell {
    
    // MARK: Properties
    open private(set) var expanded = false
    
    open func setExpanded(_ expanded: Bool, animated: Bool) {
        self.expanded = expanded
    }
    
}
