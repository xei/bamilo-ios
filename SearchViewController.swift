//
//  SearchViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

@objc protocol SearchViewControllerDelegate {
    @objc optional func searchByString(queryString: String)
    @objc optional func searchBySuggestion()
}

class SearchViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, DataServiceProtocol, UITextFieldDelegate {

    @IBOutlet private weak var searchBarContainer: UIView!
    @IBOutlet private weak var returnButton: UIButton!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    private var previousRequestTask: URLSessionTask?
    weak var delegate: SearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchTextField.delegate = self
        
        self.searchTextField.becomeFirstResponder()
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
        self.previousRequestTask = SearchSuggestionDataManager.sharedInstance.getSuggestion(self, queryString: sender.text!) { (data, errors) in
            self.previousRequestTask = nil
            if let searchSuggestion = data as? SearchSuggestion, errors == nil {
                self.bind(searchSuggestion, forRequestId: 0)
            }
        }

    }
    
    //MARK: - status bar style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let queryString = textField.text {
            self.delegate?.searchByString?(queryString: queryString)
        }
        return true
    }
    
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        
    }
}
