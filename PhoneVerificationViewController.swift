//
//  PhoneVerificationViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/23/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

@objc protocol PhoneVerificationViewControllerDelegate: NSObjectProtocol {
    func finishedVerifingPhone(callBack:() -> Void)
}

@objc class PhoneVerificationViewController: AuthenticationBaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var tokenCodeTextField: UITextField!
    @IBOutlet weak private var bottomFieldSeperatorView: UIView!
    @IBOutlet weak private var bottomOfContentConstraint: NSLayoutConstraint!
    @IBOutlet weak private var timingLabel: UILabel!
    @IBOutlet weak private var retryTitleLabel: UILabel!
    @IBOutlet weak private var retryContainerView: UIView!
    @IBOutlet weak private var submissionButton: UIButton!
    @IBOutlet weak private var retryButton: UIButton!
    
    private var viewWillDisapear = false
    private let defaultContentBottomConstriant: CGFloat = 20
    private var timer: Timer?
    private let countDownSeconds = 30
    private var remainingSeconds = 0
    
    weak var delegate: PhoneVerificationViewControllerDelegate?
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tokenCodeTextField.delegate = self
        self.tokenCodeTextField.becomeFirstResponder()
        
        self.applyStyle()
        self.runTimer(seconds: self.countDownSeconds)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        tokenCodeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if let inputToken = textField.text {
            if inputToken.count <= 5 {
                textField.text = inputToken.convertTo(language: .arabic)
                if inputToken.count == 5 {
                    self.submitForm()
                }
                return
            }
            textField.text?.remove(at: inputToken.index(before: inputToken.endIndex))
        }
    }
    
    private func getTitleLabelMessage(phoneString: String) -> String {
        return "کد تایید به شماره زیر شما ارسال شد \n \(phoneString)".convertTo(language: .arabic)
    }
    
    private func applyStyle() {
        self.titleLabel.textAlignment = .center
        self.titleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.timingLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 10), color: Theme.color(kColorGray5))
        self.tokenCodeTextField.layer.borderWidth = 0
        self.tokenCodeTextField.layer.cornerRadius = 0
        self.tokenCodeTextField.font = Theme.font(kFontVariationRegular, size: 15)
        self.tokenCodeTextField.textColor = Theme.color(kColorGray1)
        self.tokenCodeTextField.keyboardType = .numberPad
        self.tokenCodeTextField.borderStyle = .none
        
        self.retryButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorBlue))
        self.submissionButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: .white)
        self.submissionButton.backgroundColor = Theme.color(kColorOrange1)
        self.bottomOfContentConstraint.constant = defaultContentBottomConstriant
        
        self.retryTitleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 10), color: Theme.color(kColorGray5))
        self.retryTitleLabel.text = STRING_HAVENT_RECEIVED_TOKEN
        
        self.submissionButton.setTitle(STRING_OK, for: .normal)
        self.retryButton.setTitle(STRING_RESENDING, for: .normal)
        if let userPhone = self.phoneNumber {
            self.titleLabel.text = self.getTitleLabelMessage(phoneString: userPhone)
        }
        self.retryContainerView.isHidden = true
    }
    
    @objc private func updateTimer() {
        self.remainingSeconds -= 1
        if self.remainingSeconds > 0 {
            self.timingLabel.isHidden = false
            self.retryContainerView.isHidden = true
            self.updateTimingLabel(seconds: self.remainingSeconds)
        } else {
            self.timer?.invalidate()
            self.timingLabel.isHidden = true
            self.retryContainerView.fadeIn(duration: 0.15)
        }
    }
    
    private func updateTimingLabel(seconds: Int) {
        let timerText = Utility.timeString(seconds: seconds, allowedUnits: [.minute, .second]).convertTo(language: .arabic)
        self.timingLabel.text = "ارسال مجدد تا \(timerText)"
    }
    
    @IBAction func submissionButtonTapped(_ sender: Any) {
        self.submitForm()
    }
    
    private func submitForm() {
        self.delegate?.finishedVerifingPhone(callBack: {
            if let completionAction = self.completion {
                completionAction(.signupFinished)
            } else {
                self.navigationController?.pop(step: 2, animated: true)
            }
        })
    }
    
    //MARK: - helper functions for timer
    private func runTimer(seconds: Int) {
        self.remainingSeconds = seconds
        self.timingLabel.isHidden = false
        self.retryContainerView.isHidden = true
        self.updateTimingLabel(seconds: seconds)
        
        //if any previous timer exists
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: .commonModes)
    }
    
    deinit {
        //remove all observers for this view controller when it's deinitliazed
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewWillDisapear = true
        self.tokenCodeTextField.resignFirstResponder()
    
        self.timer?.invalidate()
    }
    
    func keyboardWasShown(notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardFrame: NSValue? = userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        let keyboardRectangle = keyboardFrame?.cgRectValue
        if let keyboardHeight = keyboardRectangle?.height, let tabBarHeight = MainTabBarViewController.sharedInstance()?.tabBar.frame.height {
            self.bottomOfContentConstraint.constant = keyboardHeight - tabBarHeight + defaultContentBottomConstriant
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return viewWillDisapear
    }
    
    override func getScreenName() -> String! {
        return "phoneVerification"
    }
    
    override func navBarTitleString() -> String! {
        return STRING_PHONE_VERIFICATION_CONFIRM
    }
}
