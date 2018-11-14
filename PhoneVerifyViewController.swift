//
//  PhoneVerifyViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/25/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import PinCodeTextField

protocol PhoneVerifyViewControllerDelegate {
    func userSendVerificationPinCode(pinCode: String)
    func goBackToPreviousView()
    func retrySendingCode(for identifier: String)
}

class PhoneVerifyViewController: BaseViewController {

    @IBOutlet weak var pinCodeField: PinCodeTextField!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var sendingMessageLabel: UILabel!
    @IBOutlet private weak var sendSMSRetryButton: IconButton!
    @IBOutlet private weak var timerLabel: UILabel!
    
    private var pinCodeLimitCount = 6
    private var timer: Timer?
    private var remainingSeconds = 0
    
    var phone: String?
    weak var delegate: (AuthenticationViewsDelegate & PhoneVerifyViewControllerDelegate)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        submitButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: .white)
        timerLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: .gray)
        
        submitButton.applyGradient(colours: [
            UIColor(red:0.1, green:0.21, blue:0.37, alpha:1),
            UIColor(red:0.12, green:0.31, blue:0.56, alpha:1)
        ])
        submitButton.layer.cornerRadius = 38 / 2
        submitButton.clipsToBounds = true
        pinCodeField.delegate = self
        pinCodeField.characterLimit = 5
        pinCodeField.textColor = .gray
        pinCodeField.placeholderText = "XXXXXX"
        pinCodeField.underlineColor = .gray
        pinCodeField.font = Theme.font(kFontVariationBold, size: 18)
        if #available(iOS 10.0, *) {
            pinCodeField.keyboardType = .asciiCapableNumberPad
        } else {
            pinCodeField.keyboardType = .numberPad
        }
        sendSMSRetryButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 11), color: UIColor(red:0, green:0.68, blue:0.9, alpha:1))
    }
    
    func setNumberOfDigitLimit(limit: Int) {
        pinCodeField.characterLimit = limit
        pinCodeLimitCount = limit
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopTimer()
    }
    
    private func updateHeightContent() {
        Utility.delay(duration: 0.15) {
            self.delegate?.contentSizeChanged(height: 320, for: .phoneVerify)
            self.pinCodeField.becomeFirstResponder()
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editPhoneButtonTapped(_ sender: Any) {
        self.delegate?.goBackToPreviousView()
    }
    
    @IBAction func nextStepButtonTapped(_ sender: Any) {
        guard let pinCode = pinCodeField.text, pinCode.count == pinCodeLimitCount else { return }
        self.delegate?.userSendVerificationPinCode(pinCode: pinCode)
    }
    
    @IBAction func retrySMSButtonTapped(_ sender: Any) {
        if let phone = phone  {
            self.pinCodeField.text = nil
            self.delegate?.retrySendingCode(for: phone)
        }
    }
    
    func prepareToPresent() {
        updateHeightContent()
        runTimer(seconds: 120)
        
        //update the title label
        if let phone = phone {
            sendingMessageLabel.text = "کد تایید برای \(phone.convertTo(language: .arabic)) ارسال شده است"
        }
    }
    
    private func runTimer(seconds: Int) {
        self.remainingSeconds = seconds
        self.timerLabel.isHidden = false
        self.sendSMSRetryButton.isHidden = true
        self.updateTimingLabel(seconds: seconds)

        //if any previous timer exists
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: .commonModes)
    }
    
    @objc private func updateTimer() {
        self.remainingSeconds -= 1
        if self.remainingSeconds > 0 {
            self.updateTimingLabel(seconds: self.remainingSeconds)
        } else {
            stopTimer()
        }
    }
    
    private func updateTimingLabel(seconds: Int) {
        let timerText = Utility.timeString(seconds: seconds, allowedUnits: [.minute, .second]).convertTo(language: .arabic)
        self.timerLabel.text = "\(timerText)"
    }
    
    private func stopTimer() {
        self.timer?.invalidate()
        self.timerLabel.isHidden = true
        self.sendSMSRetryButton.fadeIn(duration: 0.15)
        self.timer = nil
    }
}

extension PhoneVerifyViewController: DataServiceProtocol {
    func bind(_ data: Any!, forRequestId rid: Int32) {}
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {}
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        if let parent = self.delegate as? AuthenticationViewController {
            if !Utility.handleErrorMessages(error: error, viewController: parent) {
                var errorHandled = false
                if let errors = (error as NSError?)?.userInfo [kErrorMessages] as? [[String: String]] {
                    for var error in errors {
                        if let fieldNameParam = error["field"], fieldNameParam.count > 0, let errorMsg = error[kMessage] {
                            parent.showNotificationBarMessage(errorMsg, isSuccess: false)
                            errorHandled = true
                        }
                    }
                }
                if !errorHandled {
                    parent.showNotificationBarMessage(STRING_SERVER_CONNECTION_ERROR_MESSAGE, isSuccess: false)
                }
            }
        }
    }
}

extension PhoneVerifyViewController: PinCodeTextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: PinCodeTextField) {
        textField.text = textField.text?.convertTo(language: .arabic)
    }
    
    func textFieldValueChanged(_ textField: PinCodeTextField) {
        textField.text = textField.text?.convertTo(language: .arabic)
    }
    
    func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool {
        return true
    }
}
