//
//  TwoButtonsPurchaseControl.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/8/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class TwoButtonsPurchaseControl: BaseViewControl {
    
    private var controlView: TwoButtonsPurchaseView?
    private var shuouldGoToCardAfterAddToCard = false
    
    var product: NewProduct?
    var purchaseTrackingInfo: String?
    weak var viewCtrl:(BaseViewController & DataServiceProtocol)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.controlView = TwoButtonsPurchaseView.nibInstance()
        self.controlView?.delegate = self
        if let view = self.controlView {
            self.addAnchorMatchedSubView(view: view)
        }
    }
    
    private func prepareToAddToCart() {
        if let variations = product?.variations, variations.count >= 1 {
            let sizeVariations = variations.filter { $0.type == .size }.first
            let selectedSize = sizeVariations?.products?.filter { $0.isSelected }.first
            if let selectedSizeSimpleSku = selectedSize?.simpleSku, let viewCtrl = self.viewCtrl {
                self.requestAddToCart(simpleSku: selectedSizeSimpleSku, inViewCtrl: viewCtrl)
                return
            } else if let sizeVariationProducts = sizeVariations?.products, sizeVariationProducts.count > 0, let viewCtrl = self.viewCtrl {
                viewCtrl.performSegue(withIdentifier: "showAddToCartModal", sender: shuouldGoToCardAfterAddToCard)
                return
            }
        }
        
        if let simpleSku = self.product?.simpleSku, let viewCtrl = self.viewCtrl {
            self.requestAddToCart(simpleSku: simpleSku, inViewCtrl: viewCtrl)
        }
    }
    
    func requestAddToCart<T: BaseViewController & DataServiceProtocol>(simpleSku: String, inViewCtrl: T) {
        if let productEntity = self.product {
            ProductDataManager.sharedInstance.addToCart(simpleSku: simpleSku, product: productEntity, viewCtrl: inViewCtrl) { (success, error) in
                if success {
                    if let info = self.purchaseTrackingInfo, success {
                        PurchaseBehaviourRecorder.sharedInstance.recordAddToCart(sku: productEntity.sku, trackingInfo: info)
                    }
                    
                    if self.shuouldGoToCardAfterAddToCard, let viewCtrl = self.viewCtrl {
                        MainTabBarViewController.showCart()
                        TrackerManager.postEvent(selector: EventSelectors.buyNowTappedSelector(), attributes: EventAttributes.buyNowTapped(product: productEntity, screenName: viewCtrl.getScreenName(), success: true))
                        //Track BuyNow action
                    } else {
                        self.controlView?.hideBuyNowAndAddToBasketButtons(animated: true)
                    }
                }
            }
        }
    }
    
    func makeVisibleTwoButtons(_ isVisible: Bool, animated: Bool) {
        self.controlView?.makeVisibleTwoButtons(isVisible, animated: animated)
    }
}

extension TwoButtonsPurchaseControl: TwoButtonsPurchaseViewDelegate {
    
    func buyNowButtonTapped() {
        shuouldGoToCardAfterAddToCard = true
        prepareToAddToCart()
    }
    
    func addToCartButtonTapped() {
        shuouldGoToCardAfterAddToCard = false
        prepareToAddToCart()
    }
}
