//
//  SignInViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/25/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class SignInViewController: BaseViewController, DataServiceProtocol, FormViewControlDelegate {
    
    @IBOutlet weak var tableview: UITableView!
    private var formController: FormViewControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.formController = FormViewControl()
        
        self.tableview.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        self.formController?.tableView = self.tableview
        self.formController?.delegate = self
        self.formController?.submitTitle = STRING_REGISTRATION_SUBMIT
        
        if let firstName = FormItemModel.init(textValue: "",
                                              fieldName: "login[identifier]",
                                              andIcon: UIImage(named: "ic_user_form") ,
                                              placeholder: "موبایل یا تلفن",
                                              type: .string,
                                              validation: nil,
                                              selectOptions: nil),
            let password =  FormItemModel.passWord(withFieldName: "login[password]") {
            self.formController?.formModelList = [firstName, firstName, firstName, firstName, password]
        }
        self.formController?.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.formController?.registerForKeyboardNotifications()
    }

    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        
    }
    
    //MARK: - FormViewControlDelegate
    func formSubmitButtonTapped() {
        //        CurrentUserManager.loadLocal()
        //        if CurrentUserManager.isUserLoggedIn() {
        //            let user = CurrentUserManager.user
        //            print(user)
        //        } else {
        //            AuthenticationDataManager.sharedInstance.loginUser(self, username: "aliunco90@gmail.com", password: "ali1123581321") { (data, error) in
        //                if let dict = data as? [String: Any], let user = dict[kDataContent] as? CustomerEntity, let userEntity = user.entity {
        //                    CurrentUserManager.saveUser(user: userEntity)
        //                }
        //            }
        //        }
    }
    
    func customCell(forIndexPath tableView: UITableView!, cellName: String!, indexPath: IndexPath!) -> UITableViewCell! {
        return UITableViewCell()
    }
}
