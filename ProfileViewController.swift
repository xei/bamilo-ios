//
//  ProfileViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import MessageUI

enum ProfileCellTypeId: String {
    case profileUserTableViewCell = "ProfileUserTableViewCell"
    case profileOrderTableViewCell = "ProfileOrderTableViewCell"
    case profileSimpleTableViewCell = "ProfileSimpleTableViewCell"
}

struct ProfileViewDataModel {
    var cellType: ProfileCellTypeId
    var title: String?
    var iconName: String?
    var notificationName: String?
    var selector: Selector?
}


class ProfileViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, DataServiceProtocol, MFMailComposeViewControllerDelegate{

    @IBOutlet private weak var tableView: UITableView!
    private var tableViewDataSource: [[ProfileViewDataModel]]?
    private let footerSectionHeight: CGFloat = 7
    private var viewWillApearedOnceOrMore = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = Theme.color(kColorVeryLightGray)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.register(UINib(nibName: ProfileUserTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: ProfileCellTypeId.profileUserTableViewCell.rawValue)
        self.tableView.register(UINib(nibName: ProfileOrderTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: ProfileCellTypeId.profileOrderTableViewCell.rawValue)
        self.tableView.register(UINib(nibName: ProfileSimpleTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: ProfileCellTypeId.profileSimpleTableViewCell.rawValue)
        
        //To remove sticky behaviour of footers
        let dummyView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 40))
        self.tableView.tableFooterView = dummyView;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -40, 0);
        
        
        self.updateTableViewDataSource()
        self.tableView.reloadData()
        
        //TODO: these codes must be removed when tab bar is ok and there is no need for JABaseViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.viewWillApearedOnceOrMore {
            self.updateTableViewDataSource()
            self.tableView.reloadData()
        }
        self.viewWillApearedOnceOrMore = true
    }
    
    override func updateNavBar() {
        super.updateNavBar()

        self.navBarLayout.showSearchButton = false
        self.navBarLayout.showBackButton = false
        self.navBarLayout.showCartButton = false
        self.navBarLayout.showDoneButton = false
        self.navBarLayout.showLogo = false
        self.navBarLayout.title = STRING_PROFILE
    }
    
    func updateTableViewDataSource() {
        
        self.tableViewDataSource = [
            [ProfileViewDataModel(cellType: .profileUserTableViewCell, title: nil, iconName: nil, notificationName: nil, selector: #selector(showLogin))],
            [ProfileViewDataModel(cellType: .profileSimpleTableViewCell, title: STRING_ORDER_HISTORY, iconName: "order-tracking-profile", notificationName: "NOTIFICATION_SHOW_MY_ORDERS_SCREEN", selector: nil)],
            [
                ProfileViewDataModel(cellType: .profileSimpleTableViewCell, title: STRING_PROFILE, iconName: "user-information-icons", notificationName: "NOTIFICATION_SHOW_USER_DATA_SCREEN", selector: nil),
                ProfileViewDataModel(cellType: .profileSimpleTableViewCell, title: STRING_MY_ADDRESSES, iconName: "address_profie", notificationName: nil, selector: #selector(showMyAddressViewController)),
                ProfileViewDataModel(cellType: .profileSimpleTableViewCell, title: STRING_RECENTLY_VIEWED, iconName: "recently_viewed", notificationName: "NOTIFICATION_SHOW_RECENTLY_VIEWED_SCREEN", selector: nil)
            ],
            [
                ProfileViewDataModel(cellType: .profileSimpleTableViewCell, title: STRING_CONTACT_US, iconName: "contact_us_profile", notificationName: nil, selector: #selector(callContctUs)),
                ProfileViewDataModel(cellType: .profileSimpleTableViewCell, title: STRING_SEND_IDEAS_AND_REPORT, iconName: "feedback_profile", notificationName: nil, selector: #selector(sendIdeaOrReport)),
                ProfileViewDataModel(cellType: .profileSimpleTableViewCell, title: STRING_EMAIL_TO_CS, iconName: "email_profile", notificationName: nil, selector: #selector(sendEmailToCS)),
                ProfileViewDataModel(cellType: .profileSimpleTableViewCell, title: STRING_GUID, iconName: "faq_profile", notificationName: nil, selector: #selector(showFAQ))
            ]
        ]
        
        if RICustomer.checkIfUserIsLogged() {
            self.tableViewDataSource?.append([ProfileViewDataModel(cellType: .profileSimpleTableViewCell, title: STRING_LOGOUT, iconName: "user_logout_profile", notificationName: nil, selector: #selector(logoutUser))])
        }
    }

    //MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataModel = self.tableViewDataSource?[indexPath.section][indexPath.row]
        var cell: BaseProfileTableViewCell!
        if let cellType = dataModel?.cellType {
            switch cellType {
            case .profileUserTableViewCell:
                cell = self.tableView.dequeueReusableCell(withIdentifier: ProfileUserTableViewCell.nibName(), for: indexPath) as! ProfileUserTableViewCell
                cell.update(withModel: RICustomer.getCurrent())
            case .profileOrderTableViewCell:
                cell = self.tableView.dequeueReusableCell(withIdentifier: ProfileOrderTableViewCell.nibName(), for: indexPath) as! ProfileOrderTableViewCell
                cell.update(withModel: dataModel)
            case .profileSimpleTableViewCell:
                cell = self.tableView.dequeueReusableCell(withIdentifier: ProfileSimpleTableViewCell.nibName(), for: indexPath) as! ProfileSimpleTableViewCell
                cell.update(withModel: dataModel)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewDataSource?[section].count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewDataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerSectionHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let shadowView = UIView()
        
        let gradient = CAGradientLayer()
        gradient.frame.size = CGSize(width: self.tableView.bounds.width, height: footerSectionHeight)
        let stopColor = Theme.color(kColorExtraLightGray).cgColor
        let startColor = Theme.color(kColorVeryLightGray).cgColor
        
        gradient.colors = [stopColor,startColor]
        gradient.locations = [0.0,0.5]
        shadowView.layer.addSublayer(gradient)
        
        return shadowView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let dataModel = self.tableViewDataSource?[indexPath.section][indexPath.row] {
            if let notificationName =  dataModel.notificationName  {
                NotificationCenter.default.post(name: NSNotification.Name(notificationName), object: nil, userInfo: nil)
            } else if let selector =  dataModel.selector, self.responds(to: selector) {
                self.perform(selector)
            }
        }
    }
    
    //MARK: - helper functions
    func showLogin() {
        if !RICustomer.checkIfUserIsLogged() {
            NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_SHOW_AUTHENTICATION_SCREEN"), object: nil, userInfo: nil)
        }
    }
    
    func callContctUs() {
        AlertManager.sharedInstance().confirmAlert("", text: STRING_CALL_CUSTOMER_SERVICE, confirm: STRING_OK, cancel: STRING_CANCEL) { (didSelectOk) in
            if didSelectOk {
                RICountry.getConfigurationWithSuccessBlock({ (configuration) in
                    if let tel = configuration?.phoneNumber {
                        if let url = URL(string: "tel://\(tel)"), UIApplication.shared.canOpenURL(url) {
                            if #available(iOS 10, *) {
                                UIApplication.shared.open(url)
                            } else {
                                UIApplication.shared.openURL(url)
                            }
                        }
                    }
                }, andFailureBlock: { (status, errorMessages) in
                    
                })
            }
        }
    }
    
    func showMyAddressViewController() {
        MainTabBarViewController.topNavigationController()?.requestNavigate(toNib: "AddressViewController", args: nil)
    }
    
    func logoutUser() {
        AuthenticationDataManager.sharedInstance.logoutUser(self) { (data, error) in
            self.bind(data, forRequestId: 0)
            //EVENT: LOGOUT
            TrackerManager.postEvent(
                selector: EventSelectors.logoutEventSelector(),
                attributes: EventAttributes.logout(success: true)
            )
            EmarsysPredictManager.userLoggedOut()
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_USER_LOGGED_OUT"), object: nil, userInfo: nil)
    }
    
    func showFAQ() {
        NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_DID_SELECT_TEASER_WITH_SHOP_URL"), object: nil, userInfo: ["title": STRING_GUID, "targetString": "shop_in_shop::help-ios", "show_back_button_title": ""])
    }
    
    func sendIdeaOrReport() {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "گزارش مشکلات برنامه", style: .default) { _ in
            self.sendEmail(subject: STRING_REPORT_BUG, recipient: "application@bamilo.com")
        }
        let deleteAction = UIAlertAction(title: "اشتراک‌گذاری ایده‌های نو", style: .default) { _ in
             self.sendEmail(subject: STRING_SHARE_IDEAS, recipient: "application@bamilo.com")
        }
        let cancelAction = UIAlertAction(title: STRING_CANCEL, style: .cancel) { _ in
            print("Cancelled")
        }
        
        cancelAction.setValue(Theme.color(kColorRed), forKey: "titleTextColor")
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)

        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func sendEmailToCS() {
        sendEmail(subject: nil, recipient: "support@bamilo.com")
    }
    
    func sendEmail(subject: String?, recipient: String) {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        } else {
            var messageBody = "\n\(STRING_DONT_REMOVE_INFO_EMAIL)\n\n"
            messageBody += "OS Version: \(UIDevice.current.systemVersion) \n Device Name: \(UIDevice.current.model) \n"
            if let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                messageBody += " App Version: \(appVersion)"
            }
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.setSubject(subject ?? "")
            mailComposer.setMessageBody(messageBody, isHTML: false)
            mailComposer.setToRecipients([ recipient ])
            mailComposer.mailComposeDelegate = self
            
            self.present(mailComposer, animated: true, completion: nil)
        }
    }
    
    //MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        
        //TODO: handle these legacy code with another way (when tab bar is ready)
        NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_UPDATE_CART"), object: nil, userInfo: nil)
        MainTabBarViewController.activateTabItem(rootViewClassType: JAHomeViewController.self)
        
        RICommunicationWrapper.deleteSessionCookie()
        ViewControllerManager.sharedInstance().clearCache()
    }
    
    //MARK: - DataTrackerProtocol
    override func getScreenName() -> String! {
        return "ProfileView"
    }
}
