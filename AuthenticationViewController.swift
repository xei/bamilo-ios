//
//  AthenticationViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/24/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

enum AuthenticationViewMode {
    case signIn
    case signUp
    case forgetPass
    case phoneVerify
}


class AuthenticationViewController: BaseViewController {
    
    @IBOutlet weak var signInViewContainer: UIView!
//    @IBOutlet weak var signUpViewContainer: UIView!
//    @IBOutlet weak var forgetPassViewContainer: UIView!
//    @IBOutlet weak var phoneVerifyViewContainer: UIView!
    
//    var viewMode: AuthenticationViewMode = .signIn
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
    }
    
//    private func renderView(mode: AuthenticationViewMode) {
//        [signInViewContainer, signUpViewContainer, forgetPassViewContainer, phoneVerifyViewContainer].forEach { $0?.isHidden = true }
//        switch mode {
//        case .signIn:
//             self.signInViewContainer.isHidden = false
//        case .signUp:
//            self.signUpViewContainer.isHidden = false
//        case .forgetPass:
//            self.forgetPassViewContainer.isHidden = false
//        case .phoneVerify:
//            self.phoneVerifyViewContainer.isHidden = false
//        }
//    }
}
