//
//  HomePageViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class HomePageViewController:   BaseViewController,
                                UITableViewDataSource,
                                DataServiceProtocol,
                                UITableViewDelegate,
                                BaseHomePageTeaserBoxTableViewCellDelegate,
                                TourPresenter,
                                TourSpotLightViewDelegate,
                                UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak private var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var contentContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var artificialNavbar: UIView!
    @IBOutlet weak private var artificialNavbarLogo: UIImageView!
    @IBOutlet weak private var artificialNavBarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var searchBar: SearchBarControl!
    
    private var timer: Timer?
    private var homePage: HomePage?
    private var dailyDealsIndex: Int?
    private var refreshControl: UIRefreshControl?
    private var spotLightView: TourSpotLightView?
    private var tourHandler: TourPresentingHandler?
    private var isRefreshing: Bool = false
    private var errorView: ErrorControlView?
    private var isLoaded = false
    
    private let cellTypeMapper: [HomePageTeaserType: String] = [
        .slider: HomePageSliderTableViewCell.nibName(),
        .featuredStores: HomePageFeaturedStoresTableViewCell.nibName(),
        .dailyDeals: DailyDealsTableViewCell.nibName(),
        .tiles:HomePageTileTeaserTableViewCell.nibName()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Theme.color(kColorGray10)
        self.artificialNavbar.backgroundColor = Theme.color(kColorExtraDarkBlue)
        if let navBar = self.navigationController?.navigationBar {
            self.artificialNavBarViewHeightConstraint.constant = navBar.frame.height
        }
        
        self.searchBar.searchView?.textField.delegate = self
        
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: HomePageSliderTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: HomePageTeaserType.slider.rawValue)
        self.tableView.register(UINib(nibName: HomePageFeaturedStoresTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: HomePageTeaserType.featuredStores.rawValue)
        self.tableView.register(UINib(nibName: DailyDealsTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: HomePageTeaserType.dailyDeals.rawValue)
        self.tableView.register(UINib(nibName: HomePageTileTeaserTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: HomePageTeaserType.tiles.rawValue)
        
        self.refreshControl = UIRefreshControl.init()
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        if let refreshControl = self.refreshControl {
            self.tableView.addSubview(refreshControl)
        }
        self.tableView.alwaysBounceVertical = true
        
        //start tour if it's necessary
        TourManager.shared.onBoard(presenter: self)
        
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.isLoaded = true
        //start review survey if it's necessary
        ReviewSurveyManager.runSurveyIfItsNeeded(target: self, executionType: .background)
        //to start DeeplinkManager
        DeepLinkManager.listenersReady()
    }
    
    @objc func handleRefresh() {
        self.loadingIndicator.stopAnimating()
        self.isRefreshing = true
        self.getHomePage { success in
            self.refreshControl?.endRefreshing()
            self.isRefreshing = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.homePage == nil {
            self.getHomePage()
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //To prevent refresh control to be visible (and it's gap) for the next time
        if self.isRefreshing {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func scrollToTop() {
        self.tableView.setContentOffset(.zero, animated: true)
    }
    
    private func getHomePage(callBack: ((Bool)->Void)? = nil) {
        self.recordStartLoadTime()
        HomeDataManager.sharedInstance.getHomeData(self, requestType: .background) { (data, errors) in
            self.loadingIndicator.stopAnimating()
            if errors == nil {
                callBack?(true)
                self.tableView.backgroundView = nil
                self.bind(data, forRequestId: 0)
                
                //track load time
                self.publishScreenLoadTime(withName:self.getScreenName(), withLabel: "")
            } else {
                callBack?(false)
                self.emptyTheView()
                self.errorHandler(errors, forRequestID: 0)
            }
        }
    }
    
    private func emptyTheView() {
        self.homePage = nil
        ThreadManager.execute {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cellType = self.homePage?.teasers[indexPath.row].type {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: cellType.rawValue, for: indexPath) as! BaseHomePageTeaserBoxTableViewCell
            cell.delegate = self
            if let teasers = self.homePage?.teasers, indexPath.row < teasers.count {
                cell.update(withModel: teasers[indexPath.row])
            }
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cellType = self.homePage?.teasers[indexPath.row].type, let cellCalssName = self.cellTypeMapper[cellType] {
            if let cell = AppUtility.getClassFromName(name: cellCalssName) as? HomePageTeaserHeightCalculator.Type {
                return cell.teaserHeight(model: self.homePage?.teasers[indexPath.row])
            }
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.homePage?.teasers.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //MARK: - BaseHomePageTeaserBoxTableViewCellDelegate
    func teaserItemTappedWithTargetString(target: String, teaserId: String, index: Int?) {
        if let screenName = self.getScreenName() {
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
    
    func teaserMustBeRemoved(at indexPath: IndexPath) {
        self.homePage?.teasers.remove(at: indexPath.row)
        UIView.animate(withDuration: 0.25, animations: {
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.top)
            self.tableView.endUpdates()
        })
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let homePage = data as? HomePage {
            self.removeErrorView()
            self.homePage = homePage
            ThreadManager.execute(onMainThread: { 
                self.tableView.reloadData()
            })
            if let index = self.homePage?.teasers.index(where: { $0.type == .dailyDeals }) {
                self.dailyDealsIndex = index
                if let countDown = (self.homePage?.teasers[index] as? HomePageDailyDeals)?.ramainingSeconds, countDown > 0 {
                    self.runTimer(seconds: countDown)
                }
            }
        }
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        if rid == 0 {
            self.getHomePage(callBack: { (success) in
                callBack(success)
            })
        }
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        if rid == 0 {
            self.handleGenericErrorCodesWithErrorControlView(Int32(error.code), forRequestID: rid)
        }
    }
    
    //MARK: - helper functions for timer
    private func runTimer(seconds: Int) {
        //if any previous timer exists
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: .commonModes)
    }
    
    @objc func updateTimer() {
        if let index = self.dailyDealsIndex, let interval = (self.homePage?.teasers[index] as? HomePageDailyDeals)?.ramainingSeconds {
            (self.homePage?.teasers[index] as? HomePageDailyDeals)?.ramainingSeconds = interval - 1
            self.updateCellTimer(with: interval)
            if interval - 1 < 1 {
                self.timer?.invalidate()
                self.teaserMustBeRemoved(at: IndexPath(row: index, section: 0))
            }
        } else {
            self.timer?.invalidate()
        }
    }
    
    private func updateCellTimer(with seconds: Int) {
        if let index = self.dailyDealsIndex, let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? DailyDealsTableViewCell {
            cell.updateTimer(seconds: seconds)
        }
    }
    
    private func setupSpotlight(feature: String) {
        if spotLightView == nil {
            if let tabItemView = MainTabBarViewController.getTabbarItemView(rootViewClassType: ProfileViewController.self) {
                if let tabItemFrame = tabItemView.superview?.convert(tabItemView.frame, to: nil) {
                    let profileSpotLight = TourSpotLight(withRect: tabItemFrame, shape: .circle, text: STRING_ITEM_TRACKING_HINT_1, margin: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
                    spotLightView = TourSpotLightView(frame: UIScreen.main.bounds, spotlight: [profileSpotLight])
                    spotLightView?.enableContinueLabel = true
                    spotLightView?.tourName = feature
                    spotLightView?.textLabelFont = Theme.font(kFontVariationBold, size: 16)
                    spotLightView?.continueLabelFont = Theme.font(kFontVariationBold, size: 16)
                    spotLightView?.continueLabelText = STRING_GOT_IT
                    spotLightView?.delegate = self
                }
            }
        }
        
        let window = UIApplication.shared.keyWindow!
        if let view = spotLightView {
            window.addSubview(view)
        }
        spotLightView?.start()
    }
    
    //MARK: - TourPresenter
    override func getScreenName() -> String! {
        return "HomePage"
    }
    
    func doOnBoarding(featureName: String, handler: @escaping (String, TourPresenter) -> Void) {
        if featureName == TourNames.ItemTrackings {
            setupSpotlight(feature: featureName)
            self.tourHandler = handler
        }
    }
    
    //MARK: - TourSpotLightViewDelegate
    func spotlightViewDidCleanup(_ spotlightView: TourSpotLightView) {
        self.tourHandler?(spotlightView.tourName!, self)
    }
    
    
    //MARK: - status bar style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "ShowSearchView", let destinationViewCtrl = segue.destination as? SearchViewController {
            destinationViewCtrl.parentScreenName = self.getScreenName()
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
    
    private func goToTrackableTarget(target: RITarget, category: String, label: String, screenName: String) {
        TrackerManager.postEvent(selector: EventSelectors.itemTappedSelector(), attributes: EventAttributes.itemTapped(categoryEvent: category, screenName: screenName, labelEvent: label))
        MainTabBarViewController.topNavigationController()?.openTargetString(target.targetString, purchaseInfo: BehaviourTrackingInfo.trackingInfo(category: category, label: label), currentScreenName: screenName)
    }
}
