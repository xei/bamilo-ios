//
//  ForgetPassViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/25/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ForgetPassViewController: BaseAuthenticationViewCtrl {
    
    private var phoneOrEamil: FormItemModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewMode = .forgetPass
        
        self.tableview.register(UINib(nibName: FormButtonTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: FormButtonTableViewCell.nibName())
        self.formController?.submitTitle = STRING_PASSWORD_RECOVERY
        if let phoneOrEamil = FormItemModel.init(textValue: "", fieldName: "identifier",
                                                 andIcon: UIImage(named: "ic_user_form") ,
                                                 placeholder: "ایمیل یا شماره موبایل",
                                                 type: .string,
                                                 validation: FormItemValidation.init(required: true, max: 0, min: 0, withRegxPatter: "\(String.emailRegx())|\(String.phoneRegx())"),
                                                 selectOptions: nil) {
            let signinButtonCell = FormCustomFiled()
            signinButtonCell.cellName = FormButtonTableViewCell.nibName()
            self.phoneOrEamil = phoneOrEamil
            self.formController?.formModelList = [phoneOrEamil, "submit", signinButtonCell]
        }
        self.formController?.delegate = self
        self.formController?.setupTableView()
    }
    
    
    func verifyPhone(with target: DataServiceProtocol, pinCode: String) {
        if let phone = self.phoneOrEamil?.getValue() {
            let params = ["identifier": phone, "verification": pinCode.convertTo(language: .english)]
            AuthenticationDataManager.sharedInstance.forgetPassVerify(target, params: params) { (data, error) in
                if error == nil {
                    self.delegate?.switchTo(viewMode: .changePass)
                }
            }
        }
    }
    
    private func requestForForgetPass(params: [String: String]) {
        if let phoneOrEmail = phoneOrEamil?.getValue() {
            self.delegate?.requestForVerification(from: .forgetPass, identifier: phoneOrEmail, target: self, rid: 0)
        }
    }
}

extension ForgetPassViewController: FormViewControlDelegate {
    func formSubmitButtonTapped() {
        if let valid = self.formController?.isFormValid() {
            if !valid {
                self.formController?.showAnyErrorInForm()
                return
            }
            if let params = self.formController?.getMutableDictionaryOfForm() as? [String: String] {
                requestForForgetPass(params: params)
            }
        }
    }
    
    func customCell(forIndexPath tableView: UITableView!, cellName: String!, indexPath: IndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormButtonTableViewCell.nibName(), for: indexPath) as! FormButtonTableViewCell
        cell.setTitle(title: STRING_USER_SIGNIN)
        cell.tagretMode = .signIn
        cell.delegate = self
        return cell
    }
}


extension ForgetPassViewController: FormButtonTableViewCellDelegate {
    func buttonTapped(for target: AuthenticationViewMode) {
        self.delegate?.switchTo(viewMode: target)
    }
}


extension ForgetPassViewController: DataServiceProtocol {
    func bind(_ data: Any!, forRequestId rid: Int32) {
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        self.baseErrorHandler(error, forRequestID: rid)
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {}
}
