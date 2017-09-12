//
//  HomeViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

class HomeViewController: BaseViewController, CAPSPageMenuDelegate, UIScrollViewDelegate, JATeaserPageViewDelegate {
    
    @IBOutlet private weak var searchBar: SearchBarControl!
    @IBOutlet private weak var contentContainer: UIView!
    
    
    private var pagemenu: CAPSPageMenu?
    private var navBarFollower: ScrollerBarFollower?
    private var searchBarFollower: ScrollerBarFollower?
    private var topTabBarFollower: ScrollerBarFollower?
    
    private var navBarInitialHeight: CGFloat?
    
    private var homePage: JAHomeViewController!
    private var myBamiloPage: JAHomeViewController!
    private var isLoaded = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navBar = self.navigationController?.navigationBar {
            self.navBarFollower = ScrollerBarFollower(withBarView: navBar, moveDirection: .top)
            self.navBarInitialHeight = navBar.frame.height
        }
        //Sign In View Controller
        self.homePage = JAHomeViewController()
        self.homePage?.title = STRING_HOME
        
        //Sign Up View Controller
        self.myBamiloPage = JAHomeViewController()
        self.myBamiloPage?.title = STRING_MY_BAMILO
        
        self.view.bringSubview(toFront: self.searchBar)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (!isLoaded) {
            let parameters: [AnyHashable: Any] = [  CAPSPageMenuOptionUseMenuLikeSegmentedControl: (true),
                                                    CAPSPageMenuOptionSelectionIndicatorHeight: 2,
                                                    CAPSPageMenuOptionMenuItemFont: Theme.font(kFontVariationRegular, size: 14),
                                                    CAPSPageMenuOptionSelectionIndicatorColor: Theme.color(kColorOrange),
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
            
            self.homePage.teaserPageView.delegate = self
            self.myBamiloPage.teaserPageView.delegate = self
            
            self.searchBarFollower = ScrollerBarFollower(withBarView: self.searchBar, moveDirection: .top)
            self.topTabBarFollower = ScrollerBarFollower(withBarView: self.pagemenu!.menuScrollView, moveDirection: .top)
            
            self.isLoaded = true
        }
        
        if let navBarHeight = self.navBarInitialHeight {
            self.pagemenu?.view.constraints.filter({ $0.firstAttribute == .top }).first?.constant = -navBarHeight
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
        
        self.navBarFollower?.resetBarFrame(animated: true)
        self.searchBarFollower?.resetBarFrame(animated: true)
        self.topTabBarFollower?.resetBarFrame(animated: true)
        
        NavBarUtility.changeStatusBarColor(color: UIColor.clear)
    }
    
    //MARK:- CAPSPageMenuDelegate
    func didMove(toPage controller: UIViewController!, index: Int) {
        self.navBarFollower?.resetBarFrame(animated: true)
        self.searchBarFollower?.resetBarFrame(animated: true)
        self.topTabBarFollower?.resetBarFrame(animated: true)
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
            if let navBarHeight = self.navBarInitialHeight {
                teaserPage.mainScrollView.contentInset = UIEdgeInsetsMake(navBarHeight, 0.0, 0.0, 0.0)
                teaserPage.mainScrollView.setContentOffset(CGPoint(x: 0, y: -navBarHeight), animated: false)
                
                self.navBarFollower?.followScrollView(scrollView: teaserPage.mainScrollView, delay: -navBarHeight, permittedMoveDistance: navBarHeight)
                self.searchBarFollower?.followScrollView(scrollView: teaserPage.mainScrollView, delay: -navBarHeight, permittedMoveDistance: navBarHeight)
                self.topTabBarFollower?.followScrollView(scrollView: teaserPage.mainScrollView, delay: -navBarHeight, permittedMoveDistance: navBarHeight)
            }
        }
        
    }
    
    //MARK:- NavigationBarProtocol
    override func navBarTitleView() -> UIView! {
        return NavBarUtility.navBarLogo()
    }
    
    override func navBarTitleString() -> String! {
        return STRING_HOME
    }
}
