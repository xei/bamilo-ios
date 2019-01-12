//
//  LoadingManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

@objcMembers class LoadingManager: NSObject {
    
    private static var isHiding = false
    private static var hasStopedHiding = false
    
    private static let loadingView: UIView? = {
        let loadingView = LoadingCoverView.nibInstance()
        loadingView?.alpha = 0
        loadingView?.isUserInteractionEnabled = true
        return loadingView
    }()
    
    class func showLoading() {
        showLoading(on: MainTabBarViewController.topViewController())
    }
    
    class func showLoading(on viewcontroller: Any?) {
        if let targetViewController = viewcontroller as? UIViewController {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            if let superview = self.loadingView?.superview, superview == targetViewController.view, isHiding {
                hasStopedHiding = true
                self.loadingView?.layer.removeAllAnimations()
                self.loadingView?.alpha = 1
            } else {
                self.loadingView?.frame = targetViewController.view.bounds
                if let loadingView = self.loadingView {
                    targetViewController.view.addSubview(loadingView)
                    loadingView.bindFrameToSuperviewBounds()
                }
                
                UIView.animate(withDuration: 0.15, animations: {
                    self.loadingView?.alpha = 1
                })
            }
        }
    }
    
    class func hideLoading() {
        isHiding = true
        UIView.animate(withDuration: 0.15, animations: {
            self.loadingView?.alpha = 0
        }, completion: { (finished) in
            if !hasStopedHiding {
                self.loadingView?.removeFromSuperview()
            }
            
            isHiding = false
            hasStopedHiding = false //reset this value
        })
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
