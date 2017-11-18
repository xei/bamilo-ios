//
//  Ext+UISCrollView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/25/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

extension UIScrollView {
    func killScroll() {
        if self.isScrollEnabled {
            self.setContentOffset(self.contentOffset, animated: false)
            self.isScrollEnabled = false
            self.isScrollEnabled = true
        }
    }
}
