//
//  LoadingManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

@objc class LoadingManager: NSObject {
    
    private static let loadingView: UIView? = {
        let loadingView = LoadingCoverView.nibInstance()
        loadingView?.alpha = 0
        loadingView?.isUserInteractionEnabled = true
        return loadingView
    }()
    
    static func showLoading() {
        showLoading(on: MainTabBarViewController.topViewController())
    }
    
    static func showLoading(on viewcontroller: Any?) {
        if let targetViewController = viewcontroller as? UIViewController {
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
    
    static func hideLoading() {
        UIView.animate(withDuration: 0.4, animations: {
            self.loadingView?.alpha = 0
        }, completion: { (finished) in
            self.loadingView?.removeFromSuperview()
        })
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
