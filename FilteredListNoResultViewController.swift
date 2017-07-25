//
//  FilteredListNoResultViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/24/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

protocol FilteredListNoResultViewControllerDelegate: class {
    func editFilterByNoResultView()
}

class FilteredListNoResultViewController: BaseViewController {

    @IBOutlet weak var filterviewDescLabel: UILabel!
    weak var delegate: FilteredListNoResultViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }

    @IBAction func editFilterbuttonTapped(_ sender: Any) {
        self.delegate?.editFilterByNoResultView()
    }
}
