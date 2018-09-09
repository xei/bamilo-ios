//
//  FailPaymentViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class FailPaymentViewController: BaseViewController {

    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var backToCardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.imageIcon.image = UIImage(named: "failIcon")
        self.messageLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 18), color: Theme.color(kColorPrimaryGray1))
        self.backToCardButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: .white)
        self.backToCardButton.backgroundColor = Theme.color(kColorOrange1)
        self.backToCardButton.setTitle(STRING_BACK_TO_CART, for: .normal)
        self.messageLabel.text = STRING_ORDER_FAIL
        self.backToCardButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.isHidden = false;
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    @IBAction func backToCardButtonTapped(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: -DataTrackerProtocol
    override func getScreenName() -> String! {
        return "checkoutPaymentFail"
    }
    
    //nav bar config
    override func navBarhideBackButton() -> Bool {
        return true
    }
}
