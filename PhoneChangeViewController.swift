//
//  PhoneChangeViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/29/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

protocol PhoneChangeViewControllerDelegate: class {
    func successfullyHasChangedPhone(phone: String)
}

class PhoneChangeViewController: BaseViewController, PhoneVerificationViewControllerDelegate, FormViewControlDelegate, DataServiceProtocol {

    @IBOutlet weak private var tableview: UITableView!
    private var formController: FormViewControl?
    private var phoneFieldItem: FormItemModel?
    
    weak var delegate: PhoneChangeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.formController = FormViewControl()
        self.tableview.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        self.tableview.register(UINib(nibName: CMSTableViewHeader.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: CMSTableViewHeader.nibName())
        
        self.formController?.tableView = self.tableview
        self.formController?.delegate = self
        self.formController?.submitTitle = STRING_OK
        
        if let phone = FormItemModel.phone(withFieldName: "customer[phone]"),
            let header = FormHeaderModel(headerTitle: STRING_INSERT_YOUR_PHONE) {
            header.alignMent = .center
            header.backgroundColor = .white
            self.formController?.formModelList = [header, phone]
            self.phoneFieldItem = phone
        }
        self.formController?.setupTableView()
    }
    
    func formSubmitButtonTapped() {
        if let isvalid = self.formController?.isFormValid(), !isvalid {
            self.formController?.showAnyErrorInForm()
            return
        }
        if let phone = self.phoneFieldItem?.getValue() {
            self.requestToken(for: phone)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        
        if segueName == "showPhoneVerificationViewController" {
            let destinationViewCtrl = segue.destination as? PhoneVerificationViewController
            destinationViewCtrl?.phoneNumber = self.phoneFieldItem?.getValue()
            destinationViewCtrl?.delegate = self
        }
    }
    
    //MARK : - PhoneVerificationViewControllerDelegate
    func finishedVerifingPhone(target: PhoneVerificationViewController) {
        if let phone = self.phoneFieldItem?.getValue() {
            self.delegate?.successfullyHasChangedPhone(phone: phone)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func getScreenName() -> String! {
        return "PhoneChangeView"
    }
    
    //MARK: - NavigationBarProtocol
    override func navBarTitleString() -> String! {
        return STRING_PHONE_SUBMISSION
    }
    
    override func navBarleftButton() -> NavBarLeftButtonType {
        return .close
    }
    
    //MARK: DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {}
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        if rid == 0 && !Utility.handleErrorMessages(error: error, viewController: self) {
            if let errors = (error as NSError?)?.userInfo [kErrorMessages] as? [[String: String]] {
                var errorHandled = false
                for var error in errors {
                    if let fieldNameParam = error["field"], fieldNameParam.count > 0, let errorMsg = error[kMessage], fieldNameParam == "phone" {
                        errorHandled = true
                        self.showNotificationBarMessage(errorMsg, isSuccess: false)
                    }
                }
                if errorHandled { return }
            }
            self.showNotificationBarMessage(STRING_SERVER_CONNECTION_ERROR_MESSAGE, isSuccess: false)
        }
    }
    
    private func requestToken(for cellPhone: String) {
        PhoneVerificationViewController.verificationRequest(target: self, phone: cellPhone, rid: 0, callBack: { (success) in
            if success {
                self.performSegue(withIdentifier: "showPhoneVerificationViewController", sender: nil)
            }
        })
    }
}
