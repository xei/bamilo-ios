//
//  Ext+UINavigationViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/28/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import Foundation

extension UINavigationController {
    func pop(step: Int, animated: Bool) {
        if step < self.viewControllers.count {
            let targetViewController =  viewControllers[viewControllers.count - 1 - step]
            self.popToViewController(targetViewController, animated: animated)
        } else {
            self.popToRootViewController(animated: animated)
        }
    }
}
