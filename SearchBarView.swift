//
//  SearchBarView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

protocol SearchBarViewDelegate: class {
    func searchBarTapped()
}


@objcMembers class SearchBarView: BaseControlView {
    weak var delegate: SearchBarViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .white
    }
    
    @IBAction func searchBarButtonTapped(_ sender: Any) {
        self.delegate?.searchBarTapped()
    }
    
    //TODO: when we migrate all BaseControlView we need to use it as this function implementation
    override class func nibInstance() -> SearchBarView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.last as! SearchBarView
    }
}
