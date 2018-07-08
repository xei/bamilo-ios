//
//  SubmitProductReviewViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/7/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class SubmitProductReviewViewController: BaseViewController, ProtectedViewControllerProtocol {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var submitReviewButton: IconButton!
    @IBOutlet weak var rateStarControl: RateStarControl!
    @IBOutlet weak var starDescriptionLabel: UILabel!
    @IBOutlet weak var reviewTitleTextField: UITextField!
    @IBOutlet weak var reviewCommentTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var prodcut: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShown(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        rateStarControl.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func applyStyle() {
        titleLabel.applyStyle(font: Theme.font(kFontVariationLight, size: 12), color: Theme.color(kColorGray7))
        starDescriptionLabel.applyStyle(font: Theme.font(kFontVariationBold, size: 12), color: Theme.color(kColorGray1))
        rateStarControl.enableButtons(enable: true)
        reviewTitleTextField.font = Theme.font(kFontVariationRegular, size: 13)
        reviewCommentTextView.font = Theme.font(kFontVariationRegular, size: 13)
        submitReviewButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: .white)
        submitReviewButton.setTitle(STRING_SUBMIT_LABEL, for: .normal)
        submitReviewButton.backgroundColor = Theme.color(kColorOrange1)
        reviewCommentTextView.textAlignment = .right
        
        
        let image = #imageLiteral(resourceName: "ProductComment").withRenderingMode(.alwaysTemplate)
        submitReviewButton.setImage(image, for: .normal)
        submitReviewButton.tintColor = .white
        
        rateStarControl.update(withModel: 0) //to set as 0 star
        rateValueSelected(value: 0)
    
        
        let borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1)
        
        ([reviewCommentTextView, reviewTitleTextField] as [UIView]).forEach {
            $0.layer.borderColor = borderColor.cgColor
            $0.layer.borderWidth = 1.0
            $0.layer.cornerRadius = 4.0
        }
        
        view.backgroundColor = UIColor.fromHexString(hex: "#f9f9f9")
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
    }
    
    @objc private func keyboardWillShown(notification: Notification) {
        if let kbSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect)?.size {
            let contentInsets = UIEdgeInsetsMake(0, 0, kbSize.height, 0)
            
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        let contentInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    override func navBarTitleString() -> String! {
        return STRING_ADD_COMMENT
    }
}

//MARK: - RateStarsViewDelegate
extension SubmitProductReviewViewController: RateStarsViewDelegate {
    func rateValueSelected(value: Int) {
        starDescriptionLabel.text = "\(value) \(STRING_STAR)".convertTo(language: .arabic)
    }
}
