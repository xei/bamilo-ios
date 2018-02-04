//
//  EditProfileViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/28/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class EditProfileViewController: BaseViewController, FormViewControlDelegate, ProtectedViewControllerProtocol, DataServiceProtocol {

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
            let nationalCode = FormItemModel.nationalCode("customer[national_id]"),
            let bankCard = FormItemModel.bankAccountFieldName("customer[bank_card_number]") {

            email.disabled = true
            self.birthdayFeildModel = birthday
            self.phoneFieldModel = phone
            self.formController?.formModelList = [phone, firstName, lastName, gender, email, birthday, nationalCode, bankCard]
            
        }
        
        self.formController?.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.formController?.registerForKeyboardNotifications()
        self.getContent()
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
    }
    
    //MARK: - FormViewControlDelegate
    func formSubmitButtonTapped() {
        if let previousCart = self.previousBankCartNumber, let newCart = self.bankCartFieldModel?.getValue(), previousCart.convertTo(language: .arabic) != newCart {
            AlertManager.sharedInstance().confirmAlert("", text: STRING_CALL_CUSTOMER_SERVICE, confirm: STRING_OK, cancel: STRING_CANCEL) { (didSelectOk) in
                self.submitEditProfileToServer()
            }
        } else {
            self.submitEditProfileToServer()
        }
    }
    
    private func submitEditProfileToServer() {
        let a = self.formController?.getMutableDictionaryOfForm()
    }
    
    func fieldHasBeenFocuced(_ field: InputTextFieldControl!, inFieldIndex fieldIndex: UInt) {
        if field.model == self.phoneFieldModel {
            field.input.textField.resignFirstResponder()
            self.performSegue(withIdentifier: "showPhoneChangeViewController", sender: nil)
        }
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if rid == 0, let customer = data as? RICustomer {
            ThreadManager.execute(onMainThread: {
                self.updateFormWithCustomer(customer: customer)
                //TODO: if we have any messages for profile form
                self.setHeaderMessage(message: "همینطوری یه مسیج امتحانی مینویسیم ببینیم چی میشه اینجا وقتی زیاد بنویسیم چی میشه")
            })
        }
    }
    
    private func setHeaderMessage(message: String) {
        let headerView = self.tableview.dequeueReusableHeaderFooterView(withIdentifier: CMSTableViewHeader.nibName()) as! CMSTableViewHeader
        
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
        if rid == 0 {
            if !Utility.handleErrorMessages(error: error, viewController: self) {
                self.handleGenericErrorCodesWithErrorControlView(Int32(error.code), forRequestID: rid)
            }
        }
    }
    
    
    private func updateFormWithCustomer(customer: RICustomer) {
        
        var fieldValues = [
            "customer[phone]": customer.phone ?? "",
            "customer[first_name]": customer.firstName ?? "",
            "customer[last_name]" : customer.lastName ?? "",
            "customer[email]" : customer.email ?? "",
            "customer[national_id]" : customer.nationalID ?? "",
            "customer[bank_card_number]" : customer.bankCartNumber ?? ""
        ]
        
        if let birthday = customer.birthday {
            let dateFormatter = DateFormatter(withFormat: "yyyy-MM-dd", locale: "en_US")
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            if let date = dateFormatter.date(from: birthday) {
                fieldValues["customer[birthday]"] = birthdayFeildModel?.visibleDateFormat.string(from: date) ?? ""
            }
        }
        
        if let gender = customer.gender {
            let genderMapper = ["male": STRING_MALE, "female": STRING_FEMALE]
            fieldValues["customer[gender]"] = genderMapper[gender] ?? ""
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
}
