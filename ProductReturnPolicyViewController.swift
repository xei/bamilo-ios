//
//  ProductReturnPolicyViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/4/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductReturnPolicyViewController: BaseViewController {

    @IBOutlet weak private var webView: UIWebView!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    var product: NewProduct?
    var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [view, webView].forEach{ $0?.backgroundColor = .white }
        
        if let model = product?.returnPolicyContent?.policy {
            isLoaded = true
            updateWithDescription(description: model)
        }
        webView.delegate = self
        getContent()
    }
    
    private func updateWithDescription(description: String) {
        webView.loadHTMLString(description, baseURL: nil)
    }
    
    var gettinSpecificationBussy = false
    func getContent(completion: ((Bool)-> Void)? = nil) {
        if let key = product?.returnPolicy?.cmsKey, !gettinSpecificationBussy, !isLoaded {
            activityIndicator.startAnimating()
            ProductDataManager.sharedInstance.getReturnPolicy(self, returnPolicyKey: key) { (data, error) in
                self.gettinSpecificationBussy = false
                self.activityIndicator.stopAnimating()
                if (error == nil) {
                    self.bind(data, forRequestId: 0)
                    completion?(true)
                } else {
                    self.errorHandler(error, forRequestID: 0)
                    completion?(false)
                }
            }
        } else {
            self.showNotificationBarMessage(STRING_SERVER_ERROR_MESSAGE, isSuccess: false)
        }
    }
    
    override func navBarTitleString() -> String! {
        return STRING_PRIVACY_POLICY
    }
    
    override func getScreenName() -> String! {
        return "returnPolicyView"
    }
}


//MARK: - DataServiceProtocol
extension ProductReturnPolicyViewController : DataServiceProtocol {
    
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let model = data as? ProductReturnPolicyContent, let policy = model.policy {
            product?.returnPolicyContent = ProductReturnPolicyContent(with: policy)
            updateWithDescription(description: model.policy ?? "")
            isLoaded = true
        }
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        if rid == 0 {
            if !Utility.handleErrorMessages(error: error, viewController: self) {
                self.handleGenericErrorCodesWithErrorControlView(Int32(error.code), forRequestID: rid)
            }
        }
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        self.getContent() { (succes) in
            callBack?(succes)
        }
    }
}

extension ProductReturnPolicyViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return navigationType != .linkClicked
    }
}
