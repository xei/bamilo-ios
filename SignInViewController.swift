//
//  SignInViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/25/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import Crashlytics

class SignInViewController: BaseAuthenticationViewCtrl {
    
    private var passwordFieldModel: FormItemModel?
    
    var submitButtonDisabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.formParamsName = "login"
        self.viewMode = .signIn
        
        self.tableview.register(UINib(nibName: FormButtonTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: FormButtonTableViewCell.nibName())
        self.tableview.register(UINib(nibName: FormLinkButtonTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: FormLinkButtonTableViewCell.nibName())
        
        self.tableview.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        self.formController?.submitTitle = STRING_USER_SIGNIN
        
        if let phoneOrEamil = FormItemModel.init(textValue: "",
                                              fieldName: "\(formParamsName)[identifier]",
                                              andIcon: UIImage(named: "ic_user_form") ,
                                              placeholder: "ایمیل یا شماره موبایل",
                                              type: .mobileOrEmail,
                                              validation: FormItemValidation.init(required: true, max: 0, min: 0, withRegxPatter: "\(String.emailRegx())|\(String.phoneRegx())"),
                                              selectOptions: nil),
            let password =  FormItemModel.passWord(withFieldName: "login[password]") {
            let signUpButtonCell = FormCustomFiled()
            signUpButtonCell.cellName = FormButtonTableViewCell.nibName()
            
            let forgetPass = FormCustomFiled()
            forgetPass.cellName = FormLinkButtonTableViewCell.nibName()
            passwordFieldModel = password
            self.formController?.formModelList = [phoneOrEamil, password, forgetPass,"submit", signUpButtonCell]
        }
        self.formController?.delegate = self
        self.formController?.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.formController?.registerForKeyboardNotifications()
    }
    
    private func trackSignIn(user: User?, success: Bool) {
        if let userID = user?.userID {
            Crashlytics.sharedInstance().setUserIdentifier("\(userID)")
        }
        if let name = user?.firstName, let lastName = user?.lastName {
            Crashlytics.sharedInstance().setUserName("\(name) \(lastName)")
        }
        if let email = user?.email {
            Crashlytics.sharedInstance().setUserEmail(email)
        }
        
        TrackerManager.postEvent(selector: EventSelectors.loginEventSelector(), attributes: EventAttributes.login(loginMethod: "normal", user: user, success: success))
    }
}

//MARK: - DataServiceProtocol
extension SignInViewController: DataServiceProtocol {
    
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let password = self.passwordFieldModel?.getValue() {
            if let dictionay = data as? [String: Any], let customerEntity = dictionay[kDataContent] as? CustomerEntity, let customer = customerEntity.entity {
                self.delegate?.successSignUpOrSignInWithUser(user: customer, password: password)
                self.trackSignIn(user: customer, success: true)
            }
            if rid == 0, let dataSource = data as? CustomerEntity, let customer = dataSource.entity {
                self.delegate?.successSignUpOrSignInWithUser(user: customer, password: password)
                self.trackSignIn(user: customer, success: true)
            }
        }
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
    }
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        self.baseErrorHandler(error, forRequestID: rid)
    }
}

//MARK: - FormViewControlDelegate
extension SignInViewController: FormViewControlDelegate {
    func formSubmitButtonTapped() {
        if let valid = self.formController?.isFormValid() {
            if !valid {
                self.formController?.showAnyErrorInForm()
                return
            }
            if let fields = self.formController?.getMutableDictionaryOfForm() as? [String: String] {
                AuthenticationDataManager.sharedInstance.loginUser(self, fields: fields) { (data, error) in
                    if error == nil {
                        self.bind(data, forRequestId: 0)
                        return
                    }
                    self.errorHandler(error, forRequestID: 0)
                    self.trackSignIn(user: nil, success: false)
                }
            }
        }
    }
    
    func customCell(forIndexPath tableView: UITableView!, cellName: String!, indexPath: IndexPath!) -> UITableViewCell! {
        if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FormButtonTableViewCell.nibName(), for: indexPath) as! FormButtonTableViewCell
            cell.setTitle(title: STRING_SIGNUP)
            cell.tagretMode = .signUp
            cell.delegate = self
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FormLinkButtonTableViewCell.nibName(), for: indexPath) as! FormLinkButtonTableViewCell
            cell.setTitle(title: STRING_FORGET_PASS)
            cell.tagretMode = .forgetPass
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
}


extension SignInViewController: FormButtonTableViewCellDelegate {
    func buttonTapped(for target: AuthenticationViewMode) {
        self.delegate?.switchTo(viewMode: target)
    }
}
