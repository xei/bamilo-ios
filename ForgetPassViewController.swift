//
//  ForgetPassViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/25/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ForgetPassViewController: BaseAuthenticationViewCtrl {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewMode = .forgetPass
        
        self.tableview.register(UINib(nibName: FormButtonTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: FormButtonTableViewCell.nibName())
        self.formController?.submitTitle = STRING_PASSWORD_RECOVERY
        if let phoneOrEamil = FormItemModel.init(textValue: "", fieldName: "login[identifier]",
                                                 andIcon: UIImage(named: "ic_user_form") ,
                                                 placeholder: "ایمیل یا شماره موبایل",
                                                 type: .string,
                                                 validation: FormItemValidation.init(required: true, max: 0, min: 0, withRegxPatter: "\(String.emailRegx())|\(String.phoneRegx())"),
                                                 selectOptions: nil) {
            let signinButtonCell = FormCustomFiled()
            signinButtonCell.cellName = FormButtonTableViewCell.nibName()
            self.formController?.formModelList = [phoneOrEamil,"submit", signinButtonCell]
        }
        self.formController?.delegate = self
        self.formController?.setupTableView()
    }
}

extension ForgetPassViewController: FormViewControlDelegate {
    func formSubmitButtonTapped() {
        self.delegate?.switchTo(viewMode: .phoneVerify)
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
