//
//  ProfileViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var tableView: UITableView!
    private var tableViewDataSource: [Dictionary<String, Any>]?
    let footerSectionHeight: CGFloat = 10
    
    private enum CellTypeId: String {
        case profileUserTableViewCell = "ProfileUserTableViewCell"
        case profileOrderTableViewCell = "ProfileOrderTableViewCell"
        case profileSimpleTableViewCell = "ProfileSimpleTableViewCell"
    }
    
    private struct ProfileViewDataModel {
        var cellType: CellTypeId
        var title: String
        var iconName: String
        var notificationName: String?
        var selector: Selector?
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.register(UINib(nibName: ProfileUserTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: CellTypeId.profileUserTableViewCell.rawValue)
        self.tableView.register(UINib(nibName: ProfileOrderTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: CellTypeId.profileOrderTableViewCell.rawValue)
        self.tableView.register(UINib(nibName: ProfileSimpleTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: CellTypeId.profileSimpleTableViewCell.rawValue)
    }
    
    func updateTableViewDataSource() {

    }

    //MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewDataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerSectionHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let shadowView = UIView()
        
        let gradient = CAGradientLayer()
        gradient.frame.size = CGSize(width: self.tableView.bounds.width, height: footerSectionHeight)
        let stopColor = UIColor.gray.cgColor
        let startColor = Theme.color(kColorVeryLightGray).cgColor
        
        gradient.colors = [stopColor,startColor]
        gradient.locations = [0.0,0.8]
        shadowView.layer.addSublayer(gradient)
        
        return shadowView
    }
}
