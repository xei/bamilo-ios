//
//  LoadingManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

@objcMembers class LoadingManager: NSObject {
    
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
            if let superview = self.loadingView?.superview, superview == targetViewController.view {
                return
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.loadingView?.frame = targetViewController.view.bounds
            if let loadingView = self.loadingView {
                targetViewController.view.addSubview(loadingView)
                loadingView.bindFrameToSuperviewBounds()
            }
            
            UIView.animate(withDuration: 0.4, animations: {
                self.loadingView?.alpha = 1
            })
           
        }
    }
    
    class func hideLoading() {
        UIView.animate(withDuration: 0.4, animations: {
            self.loadingView?.alpha = 0
        }, completion: { (finished) in
            self.loadingView?.removeFromSuperview()
        })
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
