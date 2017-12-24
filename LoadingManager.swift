//
//  LoadingManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

@objc class LoadingManager: NSObject {
    private static let loadingView: UIView = {
        let loadingView = UIView(frame: CGRect.zero)
        loadingView.backgroundColor = UIColor.black
        loadingView.alpha = 0.0
        loadingView.isUserInteractionEnabled = true
        return loadingView
    }()
    
    private static let loadingAnimationView: UIImageView = {    
        if let image = UIImage(named: "loadingAnimationFrame1") {
            let lastFrame: Int = 8
            let loadingAnimationView = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            loadingAnimationView.animationDuration = 1.0
            var animationFrames = [UIImage]()
            for i in 1...lastFrame {
                let frameName: String = "loadingAnimationFrame\(i)"
                if let frame = UIImage(named: frameName) {
                    animationFrames.append(frame)
                }
            }
            
            loadingAnimationView.animationImages = animationFrames
            return loadingAnimationView
        }
        
        return UIImageView()
    }()
    
    private static var isLoadingVisible: Bool = false
    
    static func showLoading() {
        showLoading(on: UIApplication.shared.keyWindow?.rootViewController)
    }
    
    static func showLoading(on viewcontroller: Any?) {
        if let targetViewController = viewcontroller as? UIViewController, isLoadingVisible == false {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            loadingView.frame = CGRect(x: 0, y: 0, width: targetViewController.view?.bounds.size.width ?? 0, height: targetViewController.view?.bounds.size.height ?? 0)
            loadingAnimationView.center = loadingView.center 
            targetViewController.view?.addSubview(loadingView)
            targetViewController.view?.addSubview(loadingAnimationView)
            loadingAnimationView.startAnimating()
            
            UIView.animate(withDuration: 0.4, animations: {() -> Void in
                self.loadingView.alpha = 0.5
                self.loadingAnimationView.alpha = 0.5
            })
            
            isLoadingVisible = true
        }
    }
    
    static func hideLoading() {
        if isLoadingVisible == true {
            UIView.animate(withDuration: 0.4, animations: {() -> Void in
                self.loadingView.alpha = 0.0
                self.loadingAnimationView.alpha = 0.0
            }, completion: {(_ finished: Bool) -> Void in
                self.loadingView.removeFromSuperview()
                self.loadingAnimationView.removeFromSuperview()
            })
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            isLoadingVisible = false
        }
    }
}
