//
//  SearchViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

@objc protocol SearchViewControllerDelegate {
    @objc optional func searchByString(queryString: String)
    @objc optional func searchBySuggestion(targetString: String)
}

class SearchViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, DataServiceProtocol, UITextFieldDelegate, UIScrollViewDelegate, SearchViewControllerDelegate {

    @IBOutlet private weak var dummyStatusbarView: UIView!
    @IBOutlet private weak var searchBarContainer: UIView!
    @IBOutlet private weak var returnButton: UIButton!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    private var previousRequestTask: URLSessionTask?
    private var suggestion: SearchSuggestion?
    private var localSavedSuggestion = LocalSearchSuggestion()
    private var keyboardCanBeDismissed = false
    private var isRecentView = false
    var parentScreenName: String?
    
    weak var delegate: SearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchTextField.delegate = self
    
        self.tableView.register(UINib(nibName: IconTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: IconTableViewCell.nibName())
        self.tableView.register(UINib(nibName: PlainTableViewHeaderCell.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: PlainTableViewHeaderCell.nibName())
        self.searchTextField.becomeFirstResponder()
        self.searchTextField.returnKeyType = .search
        
        //to remove extra tableview seperators
        self.tableView.tableFooterView = UIView()
        
        self.suggestion = self.localSavedSuggestion.load()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShown(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.keyboardCanBeDismissed = true
        self.searchTextField.resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupView() {
        self.searchBarContainer.backgroundColor = Theme.color(kColorExtraDarkBlue)
        
        self.searchTextField.backgroundColor = UIColor.white
        self.searchTextField.font = Theme.font(kFontVariationRegular, size: 13)
        let searchIconView = UIImageView(image: UIImage(named: "searchIcon"))
        searchIconView.contentMode = .scaleAspectFit
        self.searchTextField.leftViewMode = .always
        searchIconView.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        self.searchTextField.leftView = searchIconView
        self.searchTextField.textAlignment = .right
        self.searchTextField.placeholder = STRING_SEARCH_PLACEHOLDER
        self.searchTextField.autocorrectionType = .no
        self.searchTextField.autocapitalizationType = .none
        self.searchTextField.spellCheckingType = .no
        
        self.returnButton.setTitle(STRING_BACK_LABEL, for: .normal)
        self.returnButton.setTitleColor(UIColor.white, for: .normal)
        self.returnButton.titleLabel?.font = Theme.font(kFontVariationRegular, size: 13)
        
        self.dummyStatusbarView.backgroundColor = Theme.color(kColorExtraDarkBlue)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        self.previousRequestTask?.cancel()
        if sender.text?.count == 0 {
            self.suggestion = self.localSavedSuggestion.load()
            self.tableView.reloadData()
            return
        }
        self.previousRequestTask = SearchSuggestionDataManager.sharedInstance.getSuggestion(self, queryString: sender.text!) { (data, errors) in
            self.previousRequestTask = nil
            self.bind(data, forRequestId: 0)
        }
    }
    
    //MARK: - status bar style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: PlainTableViewHeaderCell.nibName()) as! PlainTableViewHeaderCell
        if let searchString = self.suggestion?.query, searchString.count > 0 {
            isRecentView = true
            headerView.titleString = section == 0 ? "\(searchString) \(STRING_IN) \(STRING_CATEGORIES)".forceRTL() : STRING_PRODUCTS
        } else {
            isRecentView = false
            if section == 0 {
                headerView.titleString = STRING_CATEGORIES
            } else if section == 1 {
                headerView.titleString = STRING_PRODUCTS
            } else if section == 2 {
                headerView.titleString = STRING_RECENT_SEARCH
            }
        }
        return headerView
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return self.keyboardCanBeDismissed
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && (self.suggestion?.categories == nil || self.suggestion?.categories?.count == 0) { return 0 }
        if section == 1 && (self.suggestion?.products == nil || self.suggestion?.products?.count == 0) { return 0 }
        if section == 2 && (self.suggestion?.searchQueries == nil || self.suggestion?.searchQueries?.count == 0) { return 0 }
        return PlainTableViewHeaderCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.nibName(), for: indexPath) as! IconTableViewCell
        if indexPath.section == 0 {
            cell.titleLabel.text = suggestion?.categories?[indexPath.row].name?.forceRTL()
            return cell
        } else if indexPath.section == 1 {
            cell.titleLabel.text = suggestion?.products?[indexPath.row].name?.forceRTL()
            cell.cellImageView.kf.setImage(with: suggestion?.products?[indexPath.row].imageUrl, options: [.transition(.fade(0.20))])
            return cell
        } else if indexPath.section == 2 {
            cell.titleLabel.text = suggestion?.searchQueries?[indexPath.row].name?.forceRTL()
            cell.cellImageView.image = UIImage(named: "ico_recentsearches")
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0, let suggestion = self.suggestion, let cats = suggestion.categories {
            return cats.count
        } else if section == 1, let suggestion = self.suggestion, let products = suggestion.products {
            return products.count
        } else if section == 2, let suggestion = self.suggestion, let searchQueries = suggestion.searchQueries {
            return searchQueries.count
        }
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = self.suggestion {
            return 3
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: false, completion: nil)
        if indexPath.section == 0 {
            if let categories = self.suggestion?.categories {
                let selectedCat = categories[indexPath.row]
                if let searchQuery = self.suggestion?.query, searchQuery.count > 0, let catName = selectedCat.name {
                    selectedCat.name = "\(searchQuery) \(STRING_IN) \(catName)"
                }
                self.localSavedSuggestion.add(category: selectedCat)
                if let target = categories[indexPath.row].target {
                    self.delegate?.searchBySuggestion?(targetString: target)
                    let trackingActionLabel = isRecentView ? "search_recent_cat" : "Search_recom_cat"
                    TrackerManager.postEvent(selector: EventSelectors.suggestionTappedSelector(), attributes: EventAttributes.searchSuggestionTapped(suggestionTitle: trackingActionLabel))
                    MainTabBarViewController.topNavigationController()?.openTargetString(target, purchaseInfo: "SearchSuggestions:::\(trackingActionLabel)")
                }
            }
        } else if indexPath.section == 1 {
            if let products = self.suggestion?.products {
                self.localSavedSuggestion.add(product: products[indexPath.row])
                if let target = products[indexPath.row].target {
                    self.delegate?.searchBySuggestion?(targetString: target)
                    let trackingActionLabel = isRecentView ? "search_recent_sku" : "Search_recom_sku"
                    TrackerManager.postEvent(selector: EventSelectors.suggestionTappedSelector(), attributes: EventAttributes.searchSuggestionTapped(suggestionTitle: trackingActionLabel))
                    MainTabBarViewController.topNavigationController()?.openTargetString(target, purchaseInfo: "SearchSuggestions:::\(trackingActionLabel)")
                }
            }
        } else if indexPath.section == 2 {
            if let searchQueries = self.suggestion?.searchQueries, let target = searchQueries[indexPath.row].target, let _ = searchQueries[indexPath.row].name {
                TrackerManager.postEvent(selector: EventSelectors.suggestionTappedSelector(), attributes: EventAttributes.searchSuggestionTapped(suggestionTitle: "search_recent_string"))
                MainTabBarViewController.topNavigationController()?.openTargetString(target, purchaseInfo: "SearchSuggestions:::search_recent_string")
            }
        }
        
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchTextField.resignFirstResponder()
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let target = RITarget.getTarget(.CATALOG_SEARCH, node: textField.text)
        self.dismiss(animated: false, completion: nil)
        //Track this action
        if let parentScreenName = parentScreenName, let searchedString = textField.text {
            TrackerManager.postEvent(selector: EventSelectors.searchBarSearchedSelector(), attributes: EventAttributes.searchBarSearched(searchString: searchedString, screenName: parentScreenName))
        }
        
        if let queryString = textField.text {
            self.delegate?.searchByString?(queryString: queryString)
            self.localSavedSuggestion.add(searchQuery: queryString)
            
            MainTabBarViewController.topNavigationController()?.openTargetString(target?.targetString, purchaseInfo: "SearchString:::\(queryString)")
        }
        
        return true
    }
    
    
    @objc private func keyboardWillShown(notification: Notification) {
        if let kbSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect)?.size {
            let contentInsets = UIEdgeInsetsMake(0, 0, kbSize.height, 0)
            
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        let contentInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let searchSuggestion = data as? SearchSuggestion {
            self.suggestion = searchSuggestion
        } else {
            self.suggestion = nil
        }
        ThreadManager.execute(onMainThread: {
            self.tableView.reloadData()
        })
    }
}
