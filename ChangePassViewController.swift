//
//  ChangePassViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/17/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ChangePassViewController: BaseAuthenticationViewCtrl {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewMode = .changePass
        
        self.formController?.submitTitle = STRING_CHANGE_PASSWORD
        
        if let password =  FormItemModel.passWord(withFieldName: "password") {
            self.formController?.formModelList = [password, "submit"]
        }
        
        self.formController?.delegate = self
        self.formController?.setupTableView()
    }
}


extension ChangePassViewController: FormViewControlDelegate {
    func formSubmitButtonTapped() {
        
    }
}
