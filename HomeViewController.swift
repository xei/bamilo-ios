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
                            JATeaserPageViewDelegate,
                            UITextFieldDelegate,
                            HomePageViewControllerDelegate {
    
    @IBOutlet private weak var searchBar: SearchBarControl!
    @IBOutlet private weak var contentContainer: UIView!
    @IBOutlet private weak var contentContainerTopConstraint: NSLayoutConstraint!
    
    
    private var pagemenu: CAPSPageMenu?
    private var navBarFollower: ScrollerBarFollower?
    private var searchBarFollower: ScrollerBarFollower?
    private var topTabBarFollower: ScrollerBarFollower?
    
    private var navBarInitialHeight: CGFloat?
    
    private var homePage: HomePageViewController!
    private var myBamiloPage: JAHomeViewController!
    private var isLoaded = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navBar = self.navigationController?.navigationBar {
            self.navBarFollower = ScrollerBarFollower(barView: navBar, moveDirection: .top)
            self.navBarInitialHeight = navBar.frame.height
        }
        //Sign In View Controller
        self.homePage = HomePageViewController(nibName: "HomePageViewController", bundle: nil)
        self.homePage?.title = STRING_HOME
    
        
        //Sign Up View Controller
        self.myBamiloPage = JAHomeViewController()
        self.myBamiloPage?.title = STRING_MY_BAMILO
        
        self.searchBar.searchView?.textField.delegate = self
        
        self.view.bringSubview(toFront: self.searchBar)
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
                                                    CAPSPageMenuOptionScrollAnimationDurationOnMenuItemTap: (150)
            ]
            self.pagemenu = CAPSPageMenu(viewControllers: [self.myBamiloPage, self.homePage], frame: self.contentContainer.bounds, options: parameters)
            self.pagemenu?.delegate = self
            if let view = self.pagemenu?.view {
                self.contentContainer.addSubview(view)
            }
            self.pagemenu?.move(toPage: 1)
            
            self.myBamiloPage.teaserPageView.delegate = self
        
            self.homePage.delegate = self
            
            if let navBarHeight = self.navBarInitialHeight {
                //update the menuScrollview top constraint to super view
                self.pagemenu?.view.constraints.filter({ $0.firstAttribute == .top }).last?.constant = navBarHeight
                
                // -- update the frame of menuScrollView --
                // After updating the top constraint of this view
                // the frame of this view will not be updated instantly, so we do it manualy to use it in ScrollVarFollower
                self.pagemenu?.menuScrollView.frame.origin.y += navBarHeight
            }
            
            self.searchBarFollower = ScrollerBarFollower(barView: self.searchBar, moveDirection: .top)
            self.topTabBarFollower = ScrollerBarFollower(barView: self.pagemenu!.menuScrollView, moveDirection: .top)
            
            
            self.setAndFollowerScrollView(scrollView: self.homePage.tableView)
            
            self.isLoaded = true
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.homePage.viewWillAppear(animated)
        self.myBamiloPage.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NavBarUtility.changeStatusBarColor(color: Theme.color(kColorExtraDarkBlue))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NavBarUtility.changeStatusBarColor(color: UIColor.clear)

        
    }
    
    //MARK:- CAPSPageMenuDelegate
    func willMove(toPage controller: UIViewController!, index: Int) {
        if let homePage = controller as? HomePageViewController,let navBarInitialHeight = self.navBarInitialHeight, let tableView = homePage.tableView {
            if tableView.contentOffset.y <= navBarInitialHeight {
                self.resetAllBarFrames()
            }
        }
        
        if let myBamilo = controller as? JAHomeViewController ,let navBarInitialHeight = self.navBarInitialHeight, let scrollView = myBamilo.teaserPageView.mainScrollView {
            if scrollView.contentOffset.y <= navBarInitialHeight {
                self.resetAllBarFrames()
            }
        }
    }
    
    private func resetAllBarFrames() {
        self.navBarFollower?.resetBarFrame(animated: false)
        self.searchBarFollower?.resetBarFrame(animated: false)
        self.topTabBarFollower?.resetBarFrame(animated: false)
    }
    
    //MARK:- UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.navBarFollower?.scrollViewDidScroll(scrollView)
        self.searchBarFollower?.scrollViewDidScroll(scrollView)
        self.topTabBarFollower?.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.navBarFollower?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        self.searchBarFollower?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        self.topTabBarFollower?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    //MARK: -JATeaserPageViewDelegate
    func teaserPageIsReady(_ teaserPage: Any!) {
        if let teaserPage = teaserPage as? JATeaserPageView {
            teaserPage.mainScrollView.delegate = self
            self.setAndFollowerScrollView(scrollView: teaserPage.mainScrollView)
        }
    }
    
    private func setAndFollowerScrollView(scrollView: UIScrollView) {
        if let navBarHeight = self.navBarInitialHeight {
            scrollView.contentInset = UIEdgeInsetsMake(navBarHeight, 0.0, 0.0, 0.0)
            scrollView.setContentOffset(CGPoint(x: 0, y: -navBarHeight), animated: false)
            
            self.navBarFollower?.followScrollView(scrollView: scrollView, delay: -navBarHeight, permittedMoveDistance: navBarHeight)
            self.searchBarFollower?.followScrollView(scrollView: scrollView, delay: -navBarHeight, permittedMoveDistance: navBarHeight)
            self.topTabBarFollower?.followScrollView(scrollView: scrollView, delay: -navBarHeight, permittedMoveDistance: navBarHeight)
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        self.resetAllBarFrames()
        self.performSegue(withIdentifier: "ShowSearchView", sender: nil)
    }
    
    //MARK:- NavigationBarProtocol
    override func navBarTitleView() -> UIView! {
        return NavBarUtility.navBarLogo()
    }
    
    override func navBarTitleString() -> String! {
        return STRING_HOME
    }
}
