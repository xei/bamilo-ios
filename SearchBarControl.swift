//
//  SearchBarControl.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class SearchBarControl: BaseViewControl, SearchBarViewDelegate {
    
    var searchView: SearchBarView?
    weak var delegate: SearchBarViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.searchView = SearchBarView.nibInstance()
        if let view = self.searchView {
            self.addAnchorMatchedSubView(view: view)
        }
        self.searchView?.delegate = self
    }
    
    
    func searchBarTapped() {
        self.delegate?.searchBarTapped()
    }
}
