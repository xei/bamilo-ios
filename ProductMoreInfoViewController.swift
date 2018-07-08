//
//  ProductMoreInfoViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/26/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit


enum SelectedViewType {
    case description
    case specicifation
}

protocol ProductMoreInfoViewControllerDelegate: class {
    func requestsForAddToCart<T: BaseViewController & DataServiceProtocol>(sku: String, viewCtrl: T)
    func needToPrepareAddToCartViewCtrl(addToCartViewCtrl: AddToCartViewController)
}

class ProductMoreInfoViewController: BaseViewController, DataServiceProtocol {
    
    var product: Product?
    var selectedViewType: SelectedViewType = .description
    weak var delegate: ProductMoreInfoViewControllerDelegate?
    
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    @IBOutlet private weak var seperatorView: UIView!
    @IBOutlet private weak var descriptionContainerView: UIView!
    @IBOutlet private weak var specificationsContainerView: UIView!
    @IBOutlet private weak var addToCartButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        
        self.segmentControl.selectedSegmentIndex = selectedViewType == .description ? 1 : 0
        indexChanged(segmentControl)
    }
    
    func applyStyle() {
        view.backgroundColor = .white
        segmentControl.setTitleTextAttributes([NSAttributedStringKey.font: Theme.font(kFontVariationRegular, size: 12)], for: .normal)
        segmentControl.tintColor = Theme.color(kColorOrange1)
        seperatorView.backgroundColor = Theme.color(kColorGray10)
        
        addToCartButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: .white)
        addToCartButton.setTitle(STRING_ADD_TO_SHOPPING_CART, for: .normal)
        addToCartButton.backgroundColor = Theme.color(kColorOrange1)
        
        let image = #imageLiteral(resourceName: "btn_cart").withRenderingMode(.alwaysTemplate)
        addToCartButton.setImage(image, for: .normal)
        addToCartButton.tintColor = .white
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.descriptionContainerView.hide()
            self.specificationsContainerView.fadeIn(duration: 0.15)
        case 1:
            self.specificationsContainerView.hide()
            self.descriptionContainerView.fadeIn(duration: 0.15)
        default: break
        }
    }
    
    
    @IBAction func addToCartButtonTapped(_ sender: Any) {
        if let simples = product?.simples {
            if simples.count >= 1 {
                let selectedSimple = simples.filter { $0.isSelected }.first
                if let selectedSimple = selectedSimple {
                    delegate?.requestsForAddToCart(sku: selectedSimple.sku, viewCtrl: self)
                } else if let presentableSimples = product?.presentableSimples, presentableSimples.count > 0 {
                    self.performSegue(withIdentifier: "showAddToCartViewController", sender: nil)
                } else if simples.count == 1, let sku = simples.first?.sku {
                    delegate?.requestsForAddToCart(sku: sku, viewCtrl: self)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "embedProductDescriptionsViewController", let viewCtrl = segue.destination as? ProductDescriptionsViewController, let description = self.product?.productDescription {
            viewCtrl.productDescription = description
        } else if segueName == "embedProductSpecificsTableViewController", let viewCtrl = segue.destination as? ProductSpecificsTableViewController , let specifications = product?.specifications {
            viewCtrl.model = specifications
        } else if segueName == "showAddToCartViewController", let viewCtrl = segue.destination as? AddToCartViewController {
            delegate?.needToPrepareAddToCartViewCtrl(addToCartViewCtrl: viewCtrl)
        }
    }
    
    override func getScreenName() -> String! {
        return "ProductMoreInfoViewController"
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        
    }
}
