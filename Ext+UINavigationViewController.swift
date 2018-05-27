//
//  Ext+UINavigationViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/28/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import Foundation

extension UINavigationController {
    @objc func pop(step: Int, animated: Bool) {
        if let targetViewController = self.previousViewController(step: step) {
            self.popToViewController(targetViewController, animated: animated)
        } else {
            self.popToRootViewController(animated: animated)
        }
    }
    
    @objc func previousViewController(step: Int) -> UIViewController? {
        if step < self.viewControllers.count {
            return viewControllers[viewControllers.count - 1 - step]
        } else if viewControllers.count > 0 {
            return viewControllers[0]
        } else {
            return nil
        }
    }
}
