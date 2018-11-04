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
    case changePhone
    case changePass
}

protocol AuthenticationViewControllerDelegate: class {
    func successfullyHasChangedPhone(phone: String)
}

protocol AuthenticationViewsDelegate: class {
    func contentSizeChanged(height: CGFloat, for viewMode: AuthenticationViewMode)
    func switchTo(viewMode: AuthenticationViewMode)
    func successSignUpOrSignInWithUser(user: User, password: String)
    func requestForVerification(from viewMode: AuthenticationViewMode, identifier: String, target: DataServiceProtocol, rid: Int32)
    func successfullyHasChangedPhone(phone: String)
}

class AuthenticationViewController: BaseViewController {
    
    @IBOutlet private weak var contentHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var signInViewContainer: UIView!
    @IBOutlet private weak var signUpViewContainer: UIView!
    @IBOutlet private weak var forgetPassViewContainer: UIView!
    @IBOutlet private weak var phoneVerifyViewContainer: UIView!
    @IBOutlet private weak var changePhoneViewContainer: UIView!
    @IBOutlet private weak var changePassViewContainer: UIView!
    
    private var signInViewController: SignInViewController?
    private var signUpViewController: SignUpViewController?
    private var forgetPassViewController: ForgetPassViewController?
    private var phoneVerifyViewController: PhoneVerifyViewController?
    private var phoneChangeViewController: PhoneChangeViewController?
    private var changePassViewController: ChangePassViewController?
    private var phoneVerificationRequestedFromViewMode: AuthenticationViewMode?
    
    @objc var successCallBack: (() -> Void)?
    var viewMode: AuthenticationViewMode = .signIn
    lazy var intialViewHeights = [AuthenticationViewMode: CGFloat]()
    weak var delegate: AuthenticationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShown(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        renderView(mode: viewMode)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Keyboard events
    @objc private func keyboardWillShown(notification: Notification) {
        print(view.bounds.size.height)
        self.setHeight(height: view.bounds.size.height, animated: true)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        if let height = intialViewHeights[viewMode] {
            self.setHeight(height: height , animated: true)
        }
    }
    
    private func renderView(mode: AuthenticationViewMode) {
        [signInViewController, signUpViewController, forgetPassViewController, phoneVerifyViewController].forEach {
            $0?.view.endEditing(true)
        }
        [signInViewContainer, signUpViewContainer, forgetPassViewContainer, phoneVerifyViewContainer, changePhoneViewContainer, changePassViewContainer].forEach {
            $0?.isHidden = true
            $0?.alpha = 0
        }
        switch mode {
        case .signIn:
             signInViewContainer.fadeIn(duration: 0.15)
             signInViewController?.updateHeightContent()
        case .signUp:
            signUpViewContainer.fadeIn(duration: 0.15)
            signUpViewController?.updateHeightContent()
        case .forgetPass:
            forgetPassViewContainer.fadeIn(duration: 0.15)
            forgetPassViewController?.updateHeightContent()
        case .phoneVerify:
            phoneVerifyViewContainer.fadeIn(duration: 0.15)
            phoneVerifyViewController?.prepareToPresent()
        case .changePhone:
            changePhoneViewContainer.fadeIn(duration: 0.15)
            phoneChangeViewController?.updateHeightContent()
        case .changePass:
            changePassViewContainer.fadeIn(duration: 0.15)
            changePassViewController?.updateHeightContent()
        }
        //update self view mode
        viewMode = mode
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "embedSignInViewController", let siginViewCtrl = segue.destination as? SignInViewController {
            siginViewCtrl.delegate = self
            signInViewController = siginViewCtrl
        } else if segueName == "embedSignUpViewController", let signUpViewCtrl = segue.destination as? SignUpViewController {
            signUpViewCtrl.delegate = self
            signUpViewController = signUpViewCtrl
        } else if segueName == "embedForgetPassViewController", let forgetPassViewCtrl = segue.destination as? ForgetPassViewController {
            forgetPassViewCtrl.delegate = self
            forgetPassViewController = forgetPassViewCtrl
        } else if segueName == "embedPhoneVerifyViewController", let phoneVerify = segue.destination as? PhoneVerifyViewController {
            phoneVerify.delegate = self
            phoneVerifyViewController = phoneVerify
        } else if segueName == "embedChangePhoneViewController", let phoneVerify = segue.destination as? PhoneChangeViewController {
            phoneVerify.delegate = self
            phoneChangeViewController = phoneVerify
        }
    }
    
    private func setHeight(height: CGFloat, animated: Bool) {
        if  self.contentHeightConstraint.constant == height { return }
        if animated {
            UIView.animate(withDuration: 0.15) {
                self.contentHeightConstraint.constant = height
                self.view.layoutIfNeeded()
            }
        } else {
            self.contentHeightConstraint.constant = height
        }
    }
}


//MARK: AuthenticationViewsDelegate
extension AuthenticationViewController: AuthenticationViewsDelegate {

    func contentSizeChanged(height: CGFloat, for viewMode: AuthenticationViewMode) {
        self.setHeight(height: height, animated: self.intialViewHeights.keys.count > 0)
        self.intialViewHeights[viewMode] = height
    }
    
    func switchTo(viewMode: AuthenticationViewMode) {
        renderView(mode: viewMode)
    }
    
    func successSignUpOrSignInWithUser(user: User, password: String) {
        CurrentUserManager.saveUser(user: user, plainPassword: password)
        self.successCallBack?()
        
        NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.UserLogin), object: user.wishListSkus, userInfo: nil)
        dismiss(animated: true, completion: nil)
    }
    
    func requestForVerification(from viewMode: AuthenticationViewMode, identifier: String, target: DataServiceProtocol, rid: Int32) {
        if viewMode == .signUp || viewMode == .changePhone {
            AuthenticationDataManager.sharedInstance.phoneVerification(target, phone: identifier, token: nil) { (data, errors) in
                if let errors = errors {
                    target.errorHandler?(errors, forRequestID: rid)
                } else {
                    self.phoneVerificationRequestedFromViewMode = viewMode
                    self.phoneVerifyViewController?.phone = identifier
                    ThreadManager.execute(onMainThread: {
                        self.switchTo(viewMode: .phoneVerify)
                    })
                }
            }
        } else if viewMode == .forgetPass {
            AuthenticationDataManager.sharedInstance.forgetPassReq(target, params: ["identifier": identifier]) { (data, error) in
                if let errors = error {
                    target.errorHandler?(errors, forRequestID: rid)
                } else {
                    let regex = try! NSRegularExpression(pattern: String.phoneRegx(), options: [])
                    let isMobile = regex.firstMatch(in: identifier, options: [], range: NSMakeRange(0, identifier.utf16.count)) != nil

                    if isMobile {
                        self.phoneVerifyViewController?.phone = identifier
                        self.phoneVerificationRequestedFromViewMode = viewMode
                        self.switchTo(viewMode: .phoneVerify)
                    } else {
                        self.showNotificationBarMessage(STRING_SUCCESS_FORGET_PASS, isSuccess: true)
                        Utility.delay(duration: 2, completion: {
                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                }
            }
        }
    }
    
    func successfullyHasChangedPhone(phone: String) {
        self.delegate?.successfullyHasChangedPhone(phone: phone)
    }
}


//MARK: PhoneVerifyViewControllerDelegate
extension AuthenticationViewController: PhoneVerifyViewControllerDelegate {
    
    func retrySendingCode(for identifier: String) {
        if let previousMode = self.phoneVerificationRequestedFromViewMode, let target = self.phoneVerifyViewController {
            self.requestForVerification(from: previousMode, identifier: identifier, target: target, rid: 0)
        }
    }

    func goBackToPreviousView() {
        if let previousMode = self.phoneVerificationRequestedFromViewMode {
            self.switchTo(viewMode: previousMode)
        }
    }
    
    func userSendVerificationPinCode(pinCode: String) {
        guard let viewMode = self.phoneVerificationRequestedFromViewMode, let phoneVerifyViewCtrl = self.phoneVerifyViewController else { return }
        
        if viewMode == .signUp {
            self.signUpViewController?.verifyPhoneForSignUp(with: phoneVerifyViewCtrl ,pinCode: pinCode)
        } else if viewMode == .changePhone {
            self.phoneChangeViewController?.verifyPhone(with: phoneVerifyViewCtrl, pinCode: pinCode)
        } else if viewMode == .changePhone {
            self.forgetPassViewController?.verifyPhone(with: phoneVerifyViewCtrl, pinCode: pinCode)
        }
    }
    
}
