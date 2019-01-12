//
//  PhoneChangeViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/17/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class PhoneChangeViewController: BaseAuthenticationViewCtrl {
    
    var phoneField: FormItemModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        viewMode = .changePhone
        formParamsName = "customer"
        
        if let phoneField = FormItemModel.phone(withFieldName: "customer[phone]") {
            self.formController?.formModelList = [phoneField, "submit"]
            self.phoneField = phoneField
        }
        self.tableview.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        self.formController?.submitTitle = STRING_PHONE_SUBMISSION
        self.formController?.delegate = self
        self.formController?.setupTableView()
    }
    
    
    func verifyPhone(with target: DataServiceProtocol, pinCode: String) {
        if let phone = self.phoneField?.getValue() {
            AuthenticationDataManager.sharedInstance.phoneVerification(target, phone: phone, token: pinCode.convertTo(language: .english)) { (data, errors) in
                if let error = errors {
                    target.errorHandler?(error, forRequestID: 0)
                    return
                }
                self.delegate?.successfullyHasChangedPhone(phone: phone)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}


extension PhoneChangeViewController: FormViewControlDelegate {
    func formSubmitButtonTapped() {
        if let valid = self.formController?.isFormValid() {
            if !valid {
                self.formController?.showAnyErrorInForm()
                return
            }
            if let phone = phoneField?.getValue() {
                self.delegate?.requestForVerification(from: .changePhone, identifier: phone, target: self, rid: 0)
            }
        }
    }
}

extension PhoneChangeViewController: DataServiceProtocol {
    func bind(_ data: Any!, forRequestId rid: Int32) {}
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        self.baseErrorHandler(error, forRequestID: rid)
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        
    }
}
