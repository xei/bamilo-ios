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
        
        getContent()
    }
    
    private func updateWithDescription(description: String) {
        webView.loadHTMLString(description, baseURL: nil)
    }
    
    var gettinSpecificationBussy = false
    func getContent(completion: ((Bool)-> Void)? = nil) {
        if !gettinSpecificationBussy, !isLoaded {
            activityIndicator.startAnimating()
            ProductDataManager.sharedInstance.getReturnPolicy(self, returnPolicyKey: "") { (data, error) in
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
            isLoaded = true
            updateWithDescription(description: model.policy ?? "")
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
