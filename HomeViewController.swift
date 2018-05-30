//
//  HomeViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

class HomeViewController:   BaseViewController,
                            CAPSPageMenuDelegate,
                            UIScrollViewDelegate,
                            UITextFieldDelegate,
                            HomePageViewControllerDelegate,
                            MyBamiloViewControllerDelegate,
                            DataServiceProtocol {
    
    @IBOutlet private weak var searchBar: SearchBarControl!
    @IBOutlet private weak var contentContainer: UIView!
    @IBOutlet private weak var contentContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var artificialNavbar: UIView!
    @IBOutlet weak private var artificialNavbarLogo: UIImageView!
    @IBOutlet weak private var artificialNavBarViewHeightConstraint: NSLayoutConstraint!
    
    private var pagemenu: CAPSPageMenu?
    private var searchBarFollower: ScrollerBarFollower?
    private var topTabBarFollower: ScrollerBarFollower?
    private var homePage: HomePageViewController!
    private var myBamiloPage: MyBamiloViewController!
    
    private var isLoaded = false
    private var navBarInitialHeight: CGFloat?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Theme.color(kColorGray10)
        self.artificialNavbar.backgroundColor = Theme.color(kColorExtraDarkBlue)
        if let navBar = self.navigationController?.navigationBar {
            self.navBarInitialHeight = navBar.frame.height
            self.artificialNavBarViewHeightConstraint.constant = self.navBarInitialHeight ?? 44
        }
        //homePage View Controller
        self.homePage = HomePageViewController(nibName: "HomePageViewController", bundle: nil)
        self.homePage?.title = STRING_HOME
    
        
        //my bamilo View Controller
        self.myBamiloPage = MyBamiloViewController(nibName: "MyBamiloViewController", bundle: nil)
        self.myBamiloPage?.title = STRING_MY_BAMILO
        
        self.searchBar.searchView?.textField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(resetAllBarFrames(animated:)), name: NSNotification.Name(NotificationKeys.EnterForground), object: true)
        self.view.bringSubview(toFront: self.searchBar)
        
        
        self.searchBar.layer.zPosition = (self.navigationController?.navigationBar.layer.zPosition ?? 0 ) + 1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (!isLoaded) {
            if let navBarHeight = self.navBarInitialHeight {
                self.contentContainerTopConstraint.constant = -navBarHeight
            }
            
            let parameters: [AnyHashable: Any] = [  CAPSPageMenuOptionUseMenuLikeSegmentedControl: (true),
                                                    CAPSPageMenuOptionSelectionIndicatorHeight: 3,
                                                    CAPSPageMenuOptionMenuItemFont: Theme.font(kFontVariationRegular, size: 14),
                                                    CAPSPageMenuOptionSelectionIndicatorColor: Theme.color(kColorOrange1),
                                                    CAPSPageMenuOptionScrollMenuBackgroundColor: Theme.color(kColorExtraDarkBlue),
                                                    CAPSPageMenuOptionMenuHeight: 40,
                                                    CAPSPageMenuOptionBottomMenuHairlineColor: UIColor.clear,
                                                    CAPSPageMenuOptionAddBottomMenuHairline: (false),
                                                    CAPSPageMenuOptionUnselectedMenuItemLabelColor: Theme.color(kColorExtraLightGray),
                                                    CAPSPageMenuOptionSelectedMenuItemLabelColor: UIColor.white,
                                                    CAPSPageMenuOptionScrollAnimationDurationOnMenuItemTap: (150),
                                                    CAPSPageMenuOptionEnableHorizontalBounce: (false)
            ]
            self.pagemenu = CAPSPageMenu(viewControllers: [self.myBamiloPage, self.homePage], frame: self.contentContainer.bounds, options: parameters)
            self.pagemenu?.delegate = self
            if let view = self.pagemenu?.view {
                self.contentContainer.addSubview(view)
            }
            self.pagemenu?.move(toPage: 1, withAnimated: false)
    
        
            self.homePage.delegate = self
            self.myBamiloPage.delegate = self
            
            if let navBarHeight = self.navBarInitialHeight {
                //update the menuScrollview top constraint to super view
                self.pagemenu?.view.constraints.filter({ $0.firstAttribute == .top }).last?.constant = navBarHeight
                
                // -- update the frame of menuScrollView --
                // After updating the top constraint of this view
                // the frame of this view will not be updated instantly,
                // so we do it manualy to use it in ScrollVarFollower
                self.pagemenu?.menuScrollView.frame.origin.y += navBarHeight
            }
            
            self.searchBarFollower = ScrollerBarFollower(barView: self.searchBar, moveDirection: .top)
            self.topTabBarFollower = ScrollerBarFollower(barView: self.pagemenu!.menuScrollView, moveDirection: .top)
        
            self.setAndFollowerScrollView(scrollView: self.myBamiloPage.collectionView)
            self.setAndFollowerScrollView(scrollView: self.homePage.tableView)
            
            self.isLoaded = true
            
            //start review survey if it's necessary
            ReviewSurveyManager.runSurveyIfItsNeeded(target: self, executionType: .background)
            
            //to start DeeplinkManager
            DeepLinkManager.listenersReady()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.homePage.viewWillAppear(animated)
        self.myBamiloPage.viewWillAppear(animated)
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.resetAllBarFrames(animated: true)
        
        self.searchBarFollower?.resumeFollowing()
        self.topTabBarFollower?.resumeFollowing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.searchBarFollower?.pauseFollowing()
        self.topTabBarFollower?.pauseFollowing()
        self.resetAllBarFrames(animated: false)
        
        //Stop all scrolling views
        self.homePage.tableView?.killScroll()
        self.myBamiloPage.collectionView?.killScroll()
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK:- CAPSPageMenuDelegate
    func willMove(toPage controller: UIViewController!, index: Int) {
        
        self.searchBarFollower?.stopFollowing()
        self.topTabBarFollower?.stopFollowing()
        
        //Stop all scrolling views
        self.homePage.tableView?.killScroll()
        self.myBamiloPage.collectionView?.killScroll()
    
    }
    
    private func followersFollow(scrollView: UIScrollView, permittedMove: CGFloat) {
        self.searchBarFollower?.followScrollView(scrollView: scrollView, delay: -permittedMove, permittedMoveDistance: permittedMove)
        self.topTabBarFollower?.followScrollView(scrollView: scrollView, delay: -permittedMove, permittedMoveDistance: permittedMove)
    }
    
    func didMove(toPage controller: UIViewController!, index: Int) {
        
        // if the destination view controller's scrollview is on top of it
        if let homePage = controller as? HomePageViewController,let navBarInitialHeight = self.navBarInitialHeight, let tableView = homePage.tableView {
            if tableView.contentOffset.y <= 2 * navBarInitialHeight {
                self.resetAllBarFrames(animated: false)
            }
        }
        if let myBamilo = controller as? MyBamiloViewController ,let navBarInitialHeight = self.navBarInitialHeight, let scrollView = myBamilo.collectionView {
            if scrollView.contentOffset.y <= 2 * navBarInitialHeight {
                self.resetAllBarFrames(animated: false)
            }
        }
        
        if let homePage = controller as? HomePageViewController, let navBarHeight = self.navBarInitialHeight, let scrollView = homePage.tableView {
            self.followersFollow(scrollView: scrollView, permittedMove: navBarHeight)
        } else if let myBamilo = controller as? MyBamiloViewController, let navBarHeight = self.navBarInitialHeight, let scrollView = myBamilo.collectionView {
            self.followersFollow(scrollView: scrollView, permittedMove: navBarHeight)
        }
    }
    
    @objc private func resetAllBarFrames(animated: Bool) {
        self.artificialNavbarLogo.alpha = 1
        self.searchBarFollower?.resetBarFrame(animated: animated)
        self.topTabBarFollower?.resetBarFrame(animated: animated)
    }
    
    //MARK:- MyBamiloViewControllerDelegate, HomePageViewControllerDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let precentage = self.searchBarFollower?.scrollViewDidScroll(scrollView)
        self.topTabBarFollower?.scrollViewDidScroll(scrollView)
        self.artificialNavbarLogo.alpha = 1 - (precentage ?? 0)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.searchBarFollower?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        self.topTabBarFollower?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        self.artificialNavbarLogo.alpha = 1
    }
    
    func teaserItemTappedWithTargetString(target: String, teaserId: String, index: Int?) {
        if let screenName = self.homePage.getScreenName() {
            var teaserName: String?
            if let index = index {
                teaserName = "\(screenName)_\(teaserId)_\(index)"
            } else {
                teaserName = "\(screenName)_\(teaserId)_moreButton"
            }
            if let teaserName = teaserName {
                self.goToTrackableTarget(target: RITarget.parseTarget(target), category: teaserName, label: target, screenName: screenName)
            }
        }
    }
    
    func didSelectProductSku(productSku: String, recommendationLogic: String) {
        if let screenName = myBamiloPage.getScreenName() {
            self.goToTrackableTarget(target: RITarget.getTarget(.PRODUCT_DETAIL, node: productSku), category: "Emarsys", label: "\(screenName)-\(recommendationLogic)", screenName: screenName)
        }
    }
    
    private func setAndFollowerScrollView(scrollView: UIScrollView) {
        if let navBarHeight = self.navBarInitialHeight {
            scrollView.contentInset = UIEdgeInsetsMake(navBarHeight, 0.0, 0.0, 0.0)
            scrollView.setContentOffset(CGPoint(x: 0, y: -navBarHeight), animated: false)
            self.followersFollow(scrollView: scrollView, permittedMove: navBarHeight)
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        self.performSegue(withIdentifier: "ShowSearchView", sender: nil)
    }
    
    //MARK:- NavigationBarProtocol
    override func navBarTitleView() -> UIView! {
        return NavBarUtility.navBarLogo()
    }
    
    override func navBarTitleString() -> String! {
        return STRING_HOME
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "pushPDVViewController" {
            let destinationViewCtrl = segue.destination as? JAPDVViewController
            destinationViewCtrl?.productSku = sender as! String
            //if go to pdv by segue only from Emarsys recommendations (myBamilo)
            destinationViewCtrl?.purchaseTrackingInfo = "Emarsys:\(self.myBamiloPage.getScreenName())"
        } else if segueName == "ShowSearchView", let destinationViewCtrl = segue.destination as? SearchViewController {
            destinationViewCtrl.parentScreenName = self.getScreenName()
        }
    }
    
    //MARK: - status bar style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - DataTrackerProtocol
    override func getScreenName() -> String! {
        return "Home"
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        
    }
    
    private func goToTrackableTarget(target: RITarget, category: String, label: String, screenName: String) {
        TrackerManager.postEvent(selector: EventSelectors.itemTappedSelector(), attributes: EventAttributes.itemTapped(categoryEvent: category, screenName: screenName, labelEvent: label))
        MainTabBarViewController.topNavigationController()?.openTargetString(target.targetString, purchaseInfo: BehaviourTrackingInfo.trackingInfo(category: category, label: label), currentScreenName: screenName)
    }
}
