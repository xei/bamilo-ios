//
//  HomePageViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

protocol HomePageViewControllerDelegate: class {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
}

class HomePageViewController: BaseViewController, UITableViewDataSource, DataServiceProtocol, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    weak var delegate: HomePageViewControllerDelegate?
    private var homePage: HomePage?
    private let cellTypeMapper: [HomePageTeaserType: String] = [
        .slider: HomePageSliderTableViewCell.nibName()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Theme.color(kColorGray10)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: HomePageSliderTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: HomePageTeaserType.slider.rawValue)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.homePage == nil {
            HomeDataManager.sharedInstance.getHomeData(self, requestType: .background) { (data, errors) in
                self.loadingIndicator.stopAnimating()
                if errors == nil {
                    self.bind(data, forRequestId: 0)
                }
            }
        }
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cellType = self.homePage?.teasers[indexPath.row].type {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: cellType.rawValue, for: indexPath) as! BaseTableViewCell
            cell.update(withModel: self.homePage?.teasers[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cellType = self.homePage?.teasers[indexPath.row].type, let cellCalssName = self.cellTypeMapper[cellType] {
            if let cell = AppUtility.getClassFromName(name: cellCalssName) as? BaseTableViewCell.Type {
                return cell.cellHeight()
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.homePage?.teasers.count ?? 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.delegate?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let homePage = data as? HomePage {
            self.homePage = homePage
            ThreadManager.execute(onMainThread: { 
                self.tableView.reloadData()
            })
        }
    }
    
    override func navBarTitleString() -> String! {
        return STRING_HOME
    }
}
