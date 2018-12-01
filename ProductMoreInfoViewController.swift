//
//  ProductMoreInfoViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/26/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit


enum MoreInfoSelectedViewType {
    case description
    case specicifation
}

class ProductMoreInfoViewController: BaseViewController, DataServiceProtocol {
    
    var product: NewProduct?
    var animator: ZFModalTransitionAnimator?
    var selectedViewType: MoreInfoSelectedViewType = .description
    private var descriptionViewCtrl: ProductDescriptionsViewController?
    private var specifictionViewCtrl: ProductSpecificsTableViewController?
    
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    @IBOutlet private weak var seperatorView: UIView!
    @IBOutlet private weak var descriptionContainerView: UIView!
    @IBOutlet private weak var specificationsContainerView: UIView!
    @IBOutlet private weak var twoButtonCtrl: TwoButtonsPurchaseControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        
        segmentControl.selectedSegmentIndex = selectedViewType == .description ? 1 : 0
        indexChanged(segmentControl)
        
        twoButtonCtrl.viewCtrl = self
        twoButtonCtrl.product = self.product
    }
    
    func applyStyle() {
        view.backgroundColor = .white
        segmentControl.setTitleTextAttributes([NSAttributedStringKey.font: Theme.font(kFontVariationRegular, size: 12)], for: .normal)
        segmentControl.tintColor = Theme.color(kColorOrange1)
        seperatorView.backgroundColor = Theme.color(kColorGray10)
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.descriptionContainerView.hide()
            self.specificationsContainerView.fadeIn(duration: 0.15)
            
            if let viewCtrl = specifictionViewCtrl, !viewCtrl.isLoaded {
                viewCtrl.getContent()
            }
        case 1:
            self.specificationsContainerView.hide()
            self.descriptionContainerView.fadeIn(duration: 0.15)

            if let viewCtrl = descriptionViewCtrl, !viewCtrl.isLoaded {
                viewCtrl.getContent()
            }
        default: break
        }
    }
    
    private func prepareAddToCartView(addToCartViewController: AddToCartViewController){
        addToCartViewController.product = self.product
        animator = Utility.createModalBounceAnimator(viewCtrl: addToCartViewController)
        addToCartViewController.delegate = self
        addToCartViewController.transitioningDelegate = animator
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "embedProductDescriptionsViewController", let viewCtrl = segue.destination as? ProductDescriptionsViewController {
            descriptionViewCtrl = viewCtrl
            viewCtrl.product = product
        } else if segueName == "embedProductSpecificsTableViewController", let viewCtrl = segue.destination as? ProductSpecificsTableViewController {
            specifictionViewCtrl = viewCtrl
            viewCtrl.product = product
        } else if segueName == "showAddToCartModal", let viewCtrl = segue.destination as? AddToCartViewController {
            prepareAddToCartView(addToCartViewController: viewCtrl)
            viewCtrl.isBuyNow = sender as? Bool ?? false
        } else if segueName == "showProductViewController", let viewCtrl = segue.destination as? ProductDetailViewController, let product = sender as? NewProduct {
            viewCtrl.productSku = product.sku
        }
    }
    
    override func getScreenName() -> String! {
        return "ProductMoreInfoViewController"
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {}
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {}
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {}
    
}

extension ProductMoreInfoViewController: AddToCartViewControllerDelegate {
    func submitAddToCartSimple(product: NewProduct, refrence: UIViewController) {
        self.twoButtonCtrl.requestAddToCart(simpleSku: product.simpleSku ?? product.sku, inViewCtrl: self)
    }

    func didSelectOtherVariation(product: NewProduct, source: AddToCartViewController, completionHandler: @escaping ((NewProduct) -> Void)) {
        source.dismiss(animated: true) {
            self.performSegue(withIdentifier: "showProductViewController", sender: product)
        }
    }
    
    func didSelectSizeVariationFromAddToCartView(product: NewProduct) {}
    
}
