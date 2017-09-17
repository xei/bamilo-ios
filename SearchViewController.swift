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
    @objc optional func searchBySuggestion()
}

class SearchViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, DataServiceProtocol, UITextFieldDelegate, UIScrollViewDelegate, SearchViewControllerDelegate {

    @IBOutlet private weak var searchBarContainer: UIView!
    @IBOutlet private weak var returnButton: UIButton!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    private var previousRequestTask: URLSessionTask?
    private var suggestion: SearchSuggestion?
    private var localSavedSuggestion = LocalSearchSuggestion()
    
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
        
        //to remove extra tableview seperators
        self.tableView.tableFooterView = UIView()
        
        self.suggestion = self.localSavedSuggestion.load()
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
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        self.previousRequestTask?.cancel()
        if sender.text?.characters.count == 0 {
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
        if let searchString = self.searchTextField.text, searchString.characters.count > 0 {
            headerView.titleString = section == 0 ? "\(searchString) \(STRING_IN) \(STRING_CATEGORIES)".forceRTL() : STRING_PRODUCTS
        } else {
            headerView.titleString = section == 0 ? STRING_CATEGORIES : STRING_PRODUCTS
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.suggestion?.categories?.count == 0 { return 0 }
        if section == 1 && self.suggestion?.products?.count == 0 { return 0 }
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.nibName(), for: indexPath) as! IconTableViewCell
            cell.titleLabel.text = suggestion?.categories?[indexPath.row].name
            return cell
        } else if indexPath.section == 1 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: IconTableViewCell.nibName(), for: indexPath) as! IconTableViewCell
            cell.titleLabel.text = suggestion?.products?[indexPath.row].name
            cell.cellImageView.kf.setImage(with: suggestion?.products?[indexPath.row].imageUrl, options: [.transition(.fade(0.20))])
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
        }
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if let suggestion = self.suggestion {
            if let cats = suggestion.categories, cats.count > 0 { return 2 }
            if let products = suggestion.products, products.count > 0 { return 2 }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let categories = self.suggestion?.categories {
                self.localSavedSuggestion.add(category: categories[indexPath.row])
                MainTabBarViewController.topNavigationController()?.openTargetString(categories[indexPath.row].target)
            }
        } else if indexPath.section == 1 {
            if let products = self.suggestion?.products {
                self.localSavedSuggestion.add(product: products[indexPath.row])
                MainTabBarViewController.topNavigationController()?.openTargetString(products[indexPath.row].target)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchTextField.resignFirstResponder()
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let target = RITarget.getTarget(.CATALOG_SEARCH, node: textField.text)
        if let parentDataTracker = self.delegate as? DataTrackerProtocol, let searchedString = textField.text {
            TrackerManager.postEvent(selector: EventSelectors.searchBarSearchedSelector(), attributes: EventAttributes.searchBarSearched(searchString: searchedString, screenName: parentDataTracker.getScreenName()))
        }
        if let queryString = textField.text {
            self.delegate?.searchByString?(queryString: queryString)
        }
        MainTabBarViewController.topNavigationController()?.openTargetString(target?.targetString)
        self.dismiss(animated: true, completion: nil)
        return true
    }
    
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let searchSuggestion = data as? SearchSuggestion {
            self.suggestion = searchSuggestion
        } else {
            self.suggestion = self.localSavedSuggestion.load()
        }
        ThreadManager.execute(onMainThread: {
            self.tableView.reloadData()
        })
    }
}
