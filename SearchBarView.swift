//
//  SearchBarView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

@objc class SearchBarView: BaseControlView {

    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    private func setupView() {
        self.backgroundColor = Theme.color(kColorExtraDarkBlue)
        self.textField.backgroundColor = UIColor.white
        self.textField.font = Theme.font(kFontVariationRegular, size: 13)
        let searchIconView = UIImageView(image: UIImage(named: "searchIcon"))
        searchIconView.contentMode = .scaleAspectFit
        self.textField.leftViewMode = .always
        searchIconView.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        self.textField.leftView = searchIconView
        self.textField.textAlignment = .right
        self.textField.placeholder = STRING_SEARCH_PLACEHOLDER
        self.textField.tintColor = .white
    }
    
    
    //TODO: when we migrate all BaseControlView we need to use it as this function implementation
    override static func nibInstance() -> SearchBarView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.last as! SearchBarView
    }
}
