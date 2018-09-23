//
//  SubmitProductReviewViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/7/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class SubmitProductReviewViewController: BaseViewController, ProtectedViewControllerProtocol {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var submitReviewButton: IconButton!
    @IBOutlet private weak var rateStarControl: RateStarControl!
    @IBOutlet private weak var starDescriptionLabel: UILabel!
    @IBOutlet private weak var reviewTitleTextField: UITextField!
    @IBOutlet private weak var reviewCommentTextView: UITextView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var submitButtonHeightConstraint: NSLayoutConstraint!
    
    var prodcutSku: String?
    var rateValue: Int = 0
    
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
        submitReviewButton.applyStyle(font: Theme.font(kFontVariationBold, size: 15), color: .white)
        submitReviewButton.layer.cornerRadius = submitButtonHeightConstraint.constant / 2
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: submitButtonHeightConstraint.constant, right: 0)
        submitReviewButton.setTitle(STRING_SUBMIT_LABEL, for: .normal)
        submitReviewButton.backgroundColor = Theme.color(kColorOrange1)
        reviewCommentTextView.textAlignment = .right
        reviewCommentTextView.text = STRING_WRITE_COMMENT
        reviewCommentTextView.textColor = .lightGray
        reviewCommentTextView.delegate = self
        
        submitReviewButton.setImage(#imageLiteral(resourceName: "ProductComment").withRenderingMode(.alwaysTemplate), for: .normal)
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
        guard let sku = prodcutSku, self.rateValue != 0 else {
            self.showNotificationBarMessage(STRING_PLZ_ADD_RATE, isSuccess: false)
            return
        }
        let reviewText = reviewCommentTextView.text != STRING_WRITE_COMMENT ? reviewCommentTextView.text : nil
        ProductDataManager.sharedInstance.addReview(self, sku: sku, rate: rateValue, title: reviewTitleTextField.text, comment: reviewText) { (data, error) in
            if (error == nil) {
                self.bind(data, forRequestId: 0)
            } else {
                self.errorHandler(error, forRequestID: 0)
            }
        }
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
//MARK: - UITextViewDelegate
extension SubmitProductReviewViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = STRING_WRITE_COMMENT
            textView.textColor = .lightGray
        }
    }
}

//MARK: - DataServiceProtocol
extension SubmitProductReviewViewController: DataServiceProtocol {
    
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let viewCtrl = self.navigationController?.previousViewController(step: 1) as? BaseViewController {
            self.navigationController?.popViewController(animated: true)
            viewCtrl.showNotificationBarMessage(STRING_SUMISSION_SUCCESS, isSuccess: true)
        }
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        if !Utility.handleErrorMessages(error: error, viewController: self) {
            self.showNotificationBarMessage(STRING_ERROR_MESSAGE, isSuccess: false)
        }
    }
}

//MARK: - RateStarsViewDelegate
extension SubmitProductReviewViewController: RateStarsViewDelegate {
    func rateValueSelected(value: Int) {
        starDescriptionLabel.text = "\(value) \(STRING_STAR)".convertTo(language: .arabic)
        rateValue = value
    }
}
