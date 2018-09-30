//
//  EditProfileViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/28/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

struct EditProfileDataSource {
    var customer: User?
    var warningMsg: String?
}

class EditProfileViewController: BaseViewController, FormViewControlDelegate, ProtectedViewControllerProtocol, DataServiceProtocol, PhoneChangeViewControllerDelegate {

    @IBOutlet weak var tableview: UITableView!
    private var formController: FormViewControl?
    private var birthdayFeildModel: FormItemModel?
    private var phoneFieldModel : FormItemModel?
    private var bankCartFieldModel : FormItemModel?
    private var previousBankCartNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.formController = FormViewControl()
        self.tableview.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        self.tableview.register(UINib(nibName: CMSTableViewHeader.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: CMSTableViewHeader.nibName())
    
        self.formController?.tableView = self.tableview
        self.formController?.delegate = self
        self.formController?.submitTitle = STRING_REGISTRATION_SUBMIT
        
        if let phone = FormItemModel.phone(withFieldName: "customer[phone]"),
            let firstName = FormItemModel.firstNameField(withFiedName: "customer[first_name]"),
            let lastName = FormItemModel.lastName(withFieldName: "customer[last_name]"),
            let gender = FormItemModel.gender(withFieldName: "customer[gender]"),
            let email = FormItemModel.email(withFieldName: "customer[email]"),
            let birthday = FormItemModel.birthdayFieldName("customer[birthday]"),
            let nationalID = FormItemModel.nationalID("customer[national_id]"),
            let bankCard = FormItemModel.bankAccountFieldName("customer[card_number]") {

            email.disabled = true
            self.birthdayFeildModel = birthday
            self.phoneFieldModel = phone
            self.formController?.formModelList = [phone, firstName, lastName, gender, email, birthday, nationalID, bankCard]
        }
        self.formController?.setupTableView()
        self.getContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.formController?.registerForKeyboardNotifications()
    }
    
    private func getContent(callBack: ((Bool)->Void)? = nil ) {
        AuthenticationDataManager.sharedInstance.getCurrentUser(self) { (data, errors) in
            if let errors  = errors {
                callBack?(false)
                self.errorHandler(errors, forRequestID: 0)
            } else {
                callBack?(true)
                self.bind(data, forRequestId: 0)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.formController?.unregisterForKeyboardNotifications()
        
        self.view.resignFirstResponder()
    }
    
    //MARK: - FormViewControlDelegate
    func formSubmitButtonTapped() {
        if let previousCart = self.previousBankCartNumber, let newCart = self.bankCartFieldModel?.getValue(), previousCart.convertTo(language: .arabic) != newCart {
            AlertManager.sharedInstance().confirmAlert("", text: STRING_EDIT_BANK_CARD_ACKNOWLEDGEMENT, confirm: STRING_OK, cancel: STRING_CANCEL) { (didSelectOk) in
                self.submitEditProfileToServer()
            }
        } else {
            self.submitEditProfileToServer()
        }
    }
    
    private func submitEditProfileToServer() {
        if let isvalid = self.formController?.isFormValid(), !isvalid {
            self.formController?.showAnyErrorInForm()
            return
        }
        if var fields = self.formController?.getMutableDictionaryOfForm() as? [String: String] {
            AuthenticationDataManager.sharedInstance.submitEditedProfile(self, with: &fields) { (data, errors) in
                if errors == nil {
                    self.bind(data, forRequestId: 1)
                    return
                }
                self.errorHandler(errors, forRequestID: 1)
            }
        }
    }
    
    func fieldHasBeenFocuced(_ field: InputTextFieldControl!, inFieldIndex fieldIndex: UInt) {
        if field.model == self.phoneFieldModel {
            field.input.textField.resignFirstResponder()
            self.performSegue(withIdentifier: "showPhoneChangeViewController", sender: nil)
        }
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if rid == 0, let dataSource = data as? CustomerEntity, let customer = dataSource.entity {
            ThreadManager.execute(onMainThread: {
                self.updateFormWithCustomer(customer: customer)
                if let warningMessage = dataSource.warningMessage, warningMessage.count > 0 {
                    self.setHeaderMessage(message: warningMessage)
                }
            })
        } else if rid == 1 {
            if let viewCtrl = self.navigationController?.previousViewController(step: 1) as? BaseViewController {
                self.navigationController?.popViewController(animated: true)
                viewCtrl.showNotificationBarMessage(STRING_INFO_SUBMISSION_SUCCESS, isSuccess: true)
            }
        }
    }
    
    private func setHeaderMessage(message: String) {
        let headerView = self.tableview.dequeueReusableHeaderFooterView(withIdentifier: CMSTableViewHeader.nibName()) as! CMSTableViewHeader
        
        //Auto dimenssion for tableview header (with dynamic height for dyamic content size)
        headerView.setMessage(message: message)
        headerView.setNeedsUpdateConstraints()
        headerView.updateConstraintsIfNeeded()
        
        headerView.frame.size.width = UIScreen.main.bounds.width
        headerView.frame.size.height = CGFloat.greatestFiniteMagnitude
        var newFrame = headerView.frame
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        let newSize = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        newFrame.size.height = newSize.height
        headerView.frame = newFrame
        
        self.tableview.tableHeaderView = headerView
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        self.getContent { (success) in
            callBack(success)
        }
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        if !Utility.handleErrorMessages(error: error, viewController: self) {
            if rid == 0 {
                self.handleGenericErrorCodesWithErrorControlView(Int32(error.code), forRequestID: rid)
            } else if rid == 1 {
                var errorHandled = false
                if let errors = (error as NSError?)?.userInfo [kErrorMessages] as? [[String: String]] {
                    for var error in errors {
                        if let fieldNameParam = error["field"], fieldNameParam.count > 0, let errorMsg = error[kMessage] {
                            if let result = self.formController?.showErrorMessage(forField: "customer[\(fieldNameParam)]", errorMsg: errorMsg), result {
                                errorHandled = true
                            }
                        }
                    }
                }
                if !errorHandled {
                    self.showNotificationBarMessage(STRING_SERVER_CONNECTION_ERROR_MESSAGE, isSuccess: false)
                }
            }
        }
    }
    
    
    private func updateFormWithCustomer(customer: User) {
        
        var fieldValues = [
            "customer[phone]": customer.phone ?? "",
            "customer[first_name]": customer.firstName ?? "",
            "customer[last_name]" : customer.lastName ?? "",
            "customer[email]" : customer.email ?? "",
            "customer[national_id]" : customer.nationalID ?? "",
            "customer[card_number]" : customer.bankCartNumber ?? ""
        ]
        
        if let birthday = customer.birthday {
            fieldValues["customer[birthday]"] = birthdayFeildModel?.visibleDateFormat.string(from: birthday) ?? ""
        }
        
        if let gender = customer.gender {
            let genderMapper = [Gender.male.rawValue: STRING_MALE, Gender.female.rawValue: STRING_FEMALE]
            fieldValues["customer[gender]"] = genderMapper[gender.rawValue] ?? ""
        }
        
        if let modelList = self.formController?.formModelList {
            for (index, model) in modelList.enumerated() {
                if model is FormItemModel {
                    self.formController?.updateFieldIndex(UInt(index), withUpdateModelBlock: { (model) -> FormItemModel? in
                        if let fieldName = model?.fieldName {
                            model?.inputTextValue = fieldValues[fieldName]
                        }
                        return model
                    })
                }
            }
        }
        
        self.previousBankCartNumber = customer.bankCartNumber
        self.formController?.refreshView()
    }
    
    //MARK: - DataTrackerProtocol
    override func getScreenName() -> String! {
        return "Profile"
    }
    
    //MARK: - NavigationBarPrtocol
    override func navBarTitleString() -> String! {
        return STRING_PROFILE
    }
    
    //MARK: - PhoneChangeViewControllerDelegate
    func successfullyHasChangedPhone(phone: String) {
        self.phoneFieldModel?.inputTextValue = phone
        self.tableview.tableHeaderView = nil
        self.formController?.refreshView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "showPhoneChangeViewController", let navigationViewCtrl = segue.destination as? UINavigationController, let phoneChangeViewCtrl = navigationViewCtrl.viewControllers.first as? PhoneChangeViewController {
            phoneChangeViewCtrl.delegate = self
        }
    }
}
