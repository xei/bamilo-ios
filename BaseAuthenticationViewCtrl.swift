//
//  BaseAuthenticationViewCtrl.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/16/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class BaseAuthenticationViewCtrl: BaseViewController {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var titleViewHeightConstraint: NSLayoutConstraint!
    var formController: FormViewControl?
    var formParamsName: String = "login"
    var viewMode: AuthenticationViewMode = .signIn
    weak var delegate: AuthenticationViewsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //to have a gap on top of form
        self.tableview.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        self.formController = FormViewControl()
        self.formController?.tableView = self.tableview
    }
    
    // MARK: - DataServiceProtocol (error handling)
    func baseErrorHandler(_ error: Error!, forRequestID rid: Int32) {
        if let parent = self.delegate as? BaseViewController {
            if !Utility.handleErrorMessages(error: error, viewController: parent) {
                if rid == 0 {
                    var errorHandled = false
                    if let errors = (error as NSError?)?.userInfo [kErrorMessages] as? [[String: String]] {
                        for var error in errors {
                            if let fieldNameParam = error["field"], fieldNameParam.count > 0, let errorMsg = error[kMessage] {
                                if let result = self.formController?.showErrorMessage(forField: "\(formParamsName)[\(fieldNameParam)]", errorMsg: errorMsg), result {
                                    errorHandled = true
                                }
                            }
                        }
                    }
                    if !errorHandled {
                        parent.showNotificationBarMessage(STRING_SERVER_CONNECTION_ERROR_MESSAGE, isSuccess: false)
                    }
                }
            }
        }
    }
    
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func updateHeightContent() {
        Utility.delay(duration: 0.15) {
            self.delegate?.contentSizeChanged(height: self.tableview.contentSize.height + self.tableview.contentInset.top + self.tableview.contentInset.bottom + self.titleViewHeightConstraint.constant, for: self.viewMode)
        }
    }
}
