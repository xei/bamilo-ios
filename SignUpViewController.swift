//
//  SignUpViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/25/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class SignUpViewController: BaseAuthenticationViewCtrl {
    
    private var passwordFieldModel: FormItemModel?
    private var phoneFieldModel: FormItemModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        formParamsName = "customer"
        viewMode = .signUp
        
        tableview.register(UINib(nibName: FormButtonTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: FormButtonTableViewCell.nibName())
        formController?.submitTitle = STRING_SIGNUP
        
        
        if let email = FormItemModel.email(withFieldName: "\(formParamsName)[email]"),
            let phone = FormItemModel.phone(withFieldName: "\(formParamsName)[phone]"),
            let password =  FormItemModel.passWord(withFieldName: "\(formParamsName)[password]"),
            let nationID =  FormItemModel.nationalID("\(formParamsName)[national_id]") {
            email.placeholder = "\(STRING_EMAIL) *"
            phone.placeholder = "\(STRING_CELLPHONE) *"
            password.placeholder = "\(STRING_PASSWORD) *"
            nationID.placeholder = "\(STRING_NATIONAL_ID) *"
            
            self.passwordFieldModel = password
            
            let signinButtonCell = FormCustomFiled()
            signinButtonCell.cellName = FormButtonTableViewCell.nibName()
            self.formController?.formModelList = [email, phone, password, nationID, "submit", signinButtonCell]
            
            self.phoneFieldModel = phone
        }
        self.formController?.delegate = self
        self.formController?.setupTableView()
    }
    
    
    func requestForSignUp(target: DataServiceProtocol) {
        if var params = self.formController?.getMutableDictionaryOfForm() as? [String: String] {
            AuthenticationDataManager.sharedInstance.signupUser(target, with: &params) { (data, error) in
                if error == nil {
                    self.bind(data, forRequestId: 0)
                    return
                }
                self.errorHandler(error, forRequestID: 0)
            }
        }
    }
    
    
    func verifyPhoneForSignUp(with target: DataServiceProtocol, pinCode: String) {
        if let phone = self.phoneFieldModel?.getValue() {
            AuthenticationDataManager.sharedInstance.phoneVerification(target, phone: phone, token: pinCode.convertTo(language: .english)) { (data, errors) in
                if let error = errors {
                    target.errorHandler?(error, forRequestID: 0)
                    return
                }
                self.requestForSignUp(target: target)
            }
        }
    }
}

// MARK: - FormViewControlDelegate
extension SignUpViewController: FormViewControlDelegate {
    func formSubmitButtonTapped() {
        if let valid = self.formController?.isFormValid() {
            if !valid {
                self.formController?.showAnyErrorInForm()
                return
            }
            self.requestForSignUp(target: self)
        }
    }
    
    func customCell(forIndexPath tableView: UITableView!, cellName: String!, indexPath: IndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormButtonTableViewCell.nibName(), for: indexPath) as! FormButtonTableViewCell
        cell.setTitle(title: STRING_I_HAVE_ACCOUNT)
        cell.tagretMode = .signIn
        cell.delegate = self
        return cell
    }
}

extension SignUpViewController: DataServiceProtocol {
    func bind(_ data: Any!, forRequestId rid: Int32) {
        //TODO: this is not a good approach which has been contracted with server
        // and it's better to be refactored in both platforms
        if let messageList = data as? ApiDataMessageList {
            if let reason = messageList.success?.first?.reason, reason == "CUSTOMER_REGISTRATION_STEP_1_VALIDATED", let phone = phoneFieldModel?.getValue() {
                self.delegate?.requestForPhoneVerification(from: .signUp, phone: phone, target: self, rid: 9)
            }
        }
        //End TODO
        if let password = self.passwordFieldModel?.getValue() {
            if let dictionay = data as? [String: Any], let customerEntity = dictionay[kDataContent] as? CustomerEntity, let customer = customerEntity.entity {
                self.delegate?.successSignUpOrSignInWithUser(user: customer, password: password)
            }
            if rid == 0, let dataSource = data as? CustomerEntity, let customer = dataSource.entity {
                self.delegate?.successSignUpOrSignInWithUser(user: customer, password: password)
            }
        }
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        self.baseErrorHandler(error, forRequestID: rid)
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        
    }
}

extension SignUpViewController: FormButtonTableViewCellDelegate {
    func buttonTapped(for target: AuthenticationViewMode) {
        self.delegate?.switchTo(viewMode: target)
    }
}
