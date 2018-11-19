//
//  TwoButtonsPurchaseView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/8/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

protocol TwoButtonsPurchaseViewDelegate: class {
    func buyNowButtonTapped()
    func addToCartButtonTapped()
}

class TwoButtonsPurchaseView: BaseControlView {

    @IBOutlet private weak var wrapperView: UIView!
    @IBOutlet private weak var goToPaymentLabel: UILabel!
    @IBOutlet private weak var buyNowButton: IconButton!
    @IBOutlet private weak var addToBasketButton: IconButton!
    @IBOutlet private weak var goToPaymentButton: UIButton!
    @IBOutlet private weak var circleCheckedImageView: UIImageView!
    @IBOutlet private weak var leftArrowImageView: UIImageView!
    weak var delegate: TwoButtonsPurchaseViewDelegate?

    
    //MARK: UIView actions
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
    }
    
    //IBActions
    @IBAction func buyNowButtonTapped(_ sender: Any) {
        delegate?.buyNowButtonTapped()
    }
    
    
    @IBAction func addToCartButtonTapped(_ sender: Any) {
        delegate?.addToCartButtonTapped()
    }
    
    @IBAction func gotoCartButtonTapped(_ sender: Any) {
        MainTabBarViewController.showCart()
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
    private func applyStyle() {
        self.backgroundColor = .clear
        [addToBasketButton, buyNowButton].forEach {
            $0?.applyStyle(font: Theme.font(kFontVariationBold, size: 13), color: .white)
            $0?.positionStatus = 1
        }
        
        [circleCheckedImageView, leftArrowImageView].forEach { $0.applyTintColor(color: .white) }
        
        self.addToBasketButton.setTitle(STRING_ADD_TO_SHOPPING_CART, for: .normal)
        self.wrapperView.layer.cornerRadius = self.frame.height / 2
        self.wrapperView.clipsToBounds = true
        
        //wait for rendering the module
        Utility.delay(duration: 0.15) {
            self.wrapperView.applyGradient(colours: [
                UIColor(red:1, green:0.65, blue:0.05, alpha:1),
                UIColor(red:0.97, green:0.42, blue:0.11, alpha:1)
                ])
            self.addToBasketButton.applyGradient(colours: [
                UIColor(red:0.1, green:0.21, blue:0.37, alpha:1),
                UIColor(red:0.12, green:0.31, blue:0.56, alpha:1)
                ])
            self.buyNowButton.applyGradient(colours: [
                UIColor(red:1, green:0.65, blue:0.05, alpha:1),
                UIColor(red:0.97, green:0.42, blue:0.11, alpha:1)
                ])
        }
    }
    
    func hideBuyNowAndAddToBasketButtons(animated: Bool) {
        makeVisibleTwoButtons(false, animated: animated)
    }
    
    func makeVisibleTwoButtons(_ isVisible: Bool, animated: Bool) {
        if animated {
            if isVisible {
                [self.addToBasketButton, self.buyNowButton].map{ $0.fadeIn(duration: 0.15) }
            } else {
                [self.addToBasketButton, self.buyNowButton].map { $0.hide() }
            }
        } else {
            self.addToBasketButton.isHidden = !isVisible
            self.buyNowButton.isHidden = !isVisible
            self.addToBasketButton.alpha = isVisible ? 1: 0
            self.buyNowButton.alpha = isVisible ? 1: 0
        }
    }
}
