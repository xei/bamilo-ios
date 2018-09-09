//
//  ProductDescriptionsViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/26/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductDescriptionsViewController: BaseViewController {
    
    @IBOutlet weak private var webView: UIWebView!
    var product: NewProduct?
    var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [view, webView].forEach{ $0?.backgroundColor = .white }
        
        if let model = product?.descriptionHTML {
            isLoaded = true
            updateWithDescription(description: model)
        }
    }

    private func updateWithDescription(description: String) {
        webView.loadHTMLString(description, baseURL: nil)
    }
    
    var gettinSpecificationBussy = false
    func getContent(completion: ((Bool)-> Void)? = nil) {
        if let sku = product?.sku, !gettinSpecificationBussy, !isLoaded {
            ProductDataManager.sharedInstance.getDescriptions(self, sku: sku) { (data, error) in
                self.gettinSpecificationBussy = false
                if (error == nil) {
                    self.bind(data, forRequestId: 0)
                    completion?(true)
                    
                    //Track Event
                    if let product = self.product {
                        GoogleAnalyticsTracker.shared().trackEcommerceProductDetailView(product: product)
                    }
                } else {
                    self.errorHandler(error, forRequestID: 0)
                    completion?(false)
                }
            }
        }
    }
}

//MARK: - DataServiceProtocol
extension ProductDescriptionsViewController : DataServiceProtocol {
    
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let model = data as? ProductDescriptionWrapper {
            product?.descriptionHTML = model.description
            isLoaded = true
            updateWithDescription(description: model.description ?? "")
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
