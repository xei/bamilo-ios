//
//  AppreciateSurveyViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/8/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class AppreciateSurveyViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //nav bar config
    override func navBarhideBackButton() -> Bool {
        return true
    }
}
