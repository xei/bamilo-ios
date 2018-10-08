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

protocol AuthenticationViewsDelegate: class {
    func contentSizeChanged(height: CGFloat)
}

class AuthenticationViewController: BaseViewController {
    
    @IBOutlet private weak var contentHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var signInViewContainer: UIView!
//    @IBOutlet weak var signUpViewContainer: UIView!
//    @IBOutlet weak var forgetPassViewContainer: UIView!
//    @IBOutlet weak var phoneVerifyViewContainer: UIView!
    
//    var viewMode: AuthenticationViewMode = .signIn
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "embedSignInViewController", let siginViewController = segue.destination as? SignInViewController {
            siginViewController.delegate = self
        }
    }
}


//MARK: AuthenticationViewsDelegate
extension AuthenticationViewController: AuthenticationViewsDelegate {
    func contentSizeChanged(height: CGFloat) {
        self.contentHeightConstraint.constant = height
    }
}
