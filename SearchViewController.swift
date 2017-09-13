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

class SearchViewController: BaseViewController {

    @IBOutlet private weak var searchBarContainer: UIView!
    @IBOutlet private weak var returnButton: UIButton!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
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
        
        self.returnButton.setTitle(STRING_BACK_LABEL, for: .normal)
        self.returnButton.setTitleColor(UIColor.white, for: .normal)
        self.returnButton.titleLabel?.font = Theme.font(kFontVariationRegular, size: 13)
    }
    
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
