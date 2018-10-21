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
}

class PhoneVerifyViewController: BaseViewController {

    @IBOutlet weak var pinCodeField: PinCodeTextField!
    @IBOutlet private weak var submitButton: UIButton!
    
    private var pinCodeLimitCount = 6
    weak var delegate: (AuthenticationViewsDelegate & PhoneVerifyViewControllerDelegate)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        submitButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: .white)
        submitButton.applyGradient(colours: [
            UIColor(red:0.1, green:0.21, blue:0.37, alpha:1),
            UIColor(red:0.12, green:0.31, blue:0.56, alpha:1)
        ])
        submitButton.layer.cornerRadius = 38 / 2
        submitButton.clipsToBounds = true
        
        pinCodeField.delegate = self
        pinCodeField.placeholderText = "XXXXXX"
        pinCodeField.textColor = .gray
        pinCodeField.underlineColor = .gray
        pinCodeField.characterLimit = pinCodeLimitCount
        pinCodeField.font = Theme.font(kFontVariationBold, size: 18)
        if #available(iOS 10.0, *) {
            pinCodeField.keyboardType = .asciiCapableNumberPad
        } else {
            pinCodeField.keyboardType = .numberPad
        }
    }
    
    func updateHeightContent() {
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
                            parent.showNotificationBar(errorMsg, isSuccess: false)
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
