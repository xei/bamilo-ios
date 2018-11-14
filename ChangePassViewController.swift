//
//  ChangePassViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/17/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ChangePassViewController: BaseAuthenticationViewCtrl {
    
    var identifier: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewMode = .changePass
        self.formController?.submitTitle = STRING_CHANGE_PASSWORD
        if let password =  FormItemModel.passWord(withFieldName: "new_password"),
           let header = FormHeaderModel(headerTitle: "رمز عبور باید حداقل ۶ حرف و حداکثر ۱۲ حرف باشد") {
            header.alignMent = .center
            header.backgroundColor = .white
            self.formController?.formModelList = [header, password, "submit"]
        }
        self.tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        self.formController?.delegate = self
        self.formController?.setupTableView()
    }
}


extension ChangePassViewController: FormViewControlDelegate {
    func formSubmitButtonTapped() {
        let params = self.formController?.getMutableDictionaryOfForm()
        params?["identifier"] = identifier ?? ""
        if let params = params as? [String: String] {
            AuthenticationDataManager.sharedInstance.forgetPassReset(self, params: params) { (data,error) in
                if let error = error {
                    self.errorHandler(error, forRequestID: 0)
                } else {
                    self.bind(data, forRequestId: 0)
                }
            }
        }
    }
}

extension ChangePassViewController: DataServiceProtocol {
    func bind(_ data: Any!, forRequestId rid: Int32) {
        (self.delegate as? BaseViewController)?.showNotificationBarMessage(STRING_SUCCESS_FORGET_PASS_CHANGE, isSuccess: true)
        self.formController?.canBeSubmited = false
        Utility.delay(duration: 4, completion: {
            (self.delegate as? AuthenticationViewController)?.dismiss(animated: true, completion: nil)
        })
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        self.baseErrorHandler(error, forRequestID: rid)
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        
    }
}
