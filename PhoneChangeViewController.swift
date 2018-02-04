//
//  PhoneChangeViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/29/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class PhoneChangeViewController: BaseViewController, PhoneVerificationViewControllerDelegate, FormViewControlDelegate {

    @IBOutlet weak private var tableview: UITableView!
    private var formController: FormViewControl?
    private var phoneFieldItem: FormItemModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.formController = FormViewControl()
        self.tableview.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        self.tableview.register(UINib(nibName: CMSTableViewHeader.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: CMSTableViewHeader.nibName())
        
        self.formController?.tableView = self.tableview
        self.formController?.delegate = self
        self.formController?.submitTitle = STRING_OK
        
        
        if let phone = FormItemModel.phone(withFieldName: "customer[phone]"),
            let header = FormHeaderModel(headerTitle: "لطفا شماره خود را در فیلد زیر قرار دهید که ببینیم چی میشه") {
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
        self.performSegue(withIdentifier: "showPhoneVerificationViewController", sender: nil)
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
    func finishedVerifingPhone(target: PhoneVerificationViewController, callBack: () -> Void) {
        self.dismiss(animated: true, completion: nil)
        callBack()
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
}
