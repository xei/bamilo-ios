//
//  PhoneVerificationViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/23/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

@objc protocol PhoneVerificationViewControllerDelegate: NSObjectProtocol {
    func finishedVerifingPhone(target: PhoneVerificationViewController, callBack:() -> Void)
}

@objc class PhoneVerificationViewController: AuthenticationBaseViewController, UITextFieldDelegate, DataServiceProtocol {
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var tokenCodeTextField: UITextField!
    @IBOutlet weak private var bottomFieldSeperatorView: UIView!
    @IBOutlet weak private var bottomOfContentConstraint: NSLayoutConstraint!
    @IBOutlet weak private var timingLabel: UILabel!
    @IBOutlet weak private var retryTitleLabel: UILabel!
    @IBOutlet weak private var retryContainerView: UIView!
    @IBOutlet weak private var submissionButton: UIButton!
    @IBOutlet weak private var retryButton: UIButton!
    
    private var textFieldShouldEndEditing = false
    private let defaultContentBottomConstriant: CGFloat = 20
    private var timer: Timer?
    private let countDownSeconds = 120
    private var remainingSeconds = 0
    private let tokenLength = 6
    private var verificationPhoneIsFinished = false
    
    weak var delegate: PhoneVerificationViewControllerDelegate?
    var phoneNumber: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tokenCodeTextField.delegate = self
        self.tokenCodeTextField.becomeFirstResponder()
        
        self.applyStyle()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        tokenCodeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.requestToken(for: self.phoneNumber)
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if let inputToken = textField.text {
            if inputToken.count <= tokenLength {
                textField.text = inputToken.convertTo(language: .arabic)
                if inputToken.count == tokenLength {
                    self.submitForm()
                }
                return
            }
            textField.text?.remove(at: inputToken.index(before: inputToken.endIndex))
        }
    }
    
    private func getTitleLabelMessage(phoneString: String) -> String {
        return "کد تایید به شماره شما ارسال شد \n \(phoneString)".convertTo(language: .arabic)
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
        self.titleLabel.text = self.getTitleLabelMessage(phoneString: self.phoneNumber)
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
    
    @IBAction func retryButtonTapped(_ sender: Any) {
        if let message = self.getRetryActionMessages() {
            AlertManager.sharedInstance().confirmAlert("", text: message, confirm: STRING_OK, cancel: STRING_CANCEL) { (didSelectOk) in
                if didSelectOk {
                    self.requestToken(for: self.phoneNumber)
                }
            }
        }
    }
    
    private func getRetryActionMessages() -> String? {
        if let phone = self.phoneNumber {
            return "‌ارسال مجدد به شماره \(phone)".convertTo(language: .arabic)
        }
        return nil
    }
    
    private func submitForm() {
        if verificationPhoneIsFinished {
            self.performActionAfterVerification()
            return
        }
        self.controlTokenSubmission()
    }
    
    private func controlTokenSubmission(callBack: ((Bool)-> Void)? = nil ) {
        if let token = self.tokenCodeTextField.text, token.count == tokenLength {
            ThreadManager.execute(onMainThread: {
                self.submitToken(token: token, callBack: { (success) in
                    callBack?(success)
                    if success {
                        self.verificationPhoneIsFinished = true
                        self.retryButton.isEnabled = false
                        self.performActionAfterVerification()
                    }
                })
            })
        } else {
            callBack?(false)
            self.showNotificationBarMessage(STRING_ENTER_PHONE_VERIFICATION_CODE, isSuccess: false)
        }
    }
    
    private func performActionAfterVerification() {
        ThreadManager.execute {
            self.delegate?.finishedVerifingPhone(target: self, callBack: {
                self.navigationController?.pop(step: 2, animated: true)
            })
        }
    }
    
    private func requestToken(for cellPhone: String, callBack: ((Bool)->Void)? = nil) {
        self.runTimer(seconds: self.countDownSeconds)
        self.verificationRequest(phone: cellPhone, rid: 0) { success in callBack?(success) }
    }
    
    private func submitToken(token: String, callBack: ((Bool)->Void)? = nil) {
        self.verificationRequest(phone: self.phoneNumber, token: token, rid: 1) { success in callBack?(success) }
    }
    
    private func verificationRequest(phone: String, token: String? = nil, rid: Int32, callBack: @escaping (Bool)-> Void) {
        AuthenticationDataManager.sharedInstance.phoneVerification(self, phone: phone, token: token?.convertTo(language: .english)) { (data, errors) in
            if let errors = errors {
                callBack(false)
                self.errorHandler(errors, forRequestID: rid)
            } else {
                callBack(true)
            }
        }
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        //do nothing here
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        if !Utility.handleErrorMessages(error: error, viewController: self) {
            if rid == 0 {
                textFieldShouldEndEditing = true
                self.tokenCodeTextField.resignFirstResponder()
                self.handleGenericErrorCodesWithErrorControlView(Int32(error.code), forRequestID: rid)
            } else if rid == 1 {
                self.showNotificationBarMessage(STRING_SERVER_ERROR_MESSAGE, isSuccess: false)
            }
        }
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        textFieldShouldEndEditing = false
        if rid == 0 {
            self.requestToken(for: self.phoneNumber) { success in
                callBack(success)
                if success {
                    self.tokenCodeTextField.becomeFirstResponder()
                }
            }
        } else if rid == 1 {
            self.controlTokenSubmission()
        }
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
        self.textFieldShouldEndEditing = true
        self.tokenCodeTextField.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
        return textFieldShouldEndEditing
    }
    
    override func getScreenName() -> String! {
        return "phoneVerification"
    }
    
    override func navBarTitleString() -> String! {
        return STRING_PHONE_VERIFICATION_CONFIRM
    }
}
