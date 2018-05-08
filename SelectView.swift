//
//  SelectView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/11/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

protocol SelectViewItemDataSourceProtocol {
    var title: String? {get set}
    var isSelected: Bool? {get set}
}

class SelectView: BaseControlView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak internal var tableview: UITableView!
    internal var dataSource: [SelectViewItemDataSourceProtocol]?
    internal var selectionType: SelectionType = .checkbox
    var isScrollEnabled: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableview.register(UINib(nibName: SelectItemViewCell.nibName(), bundle: nil), forCellReuseIdentifier: SelectItemViewCell.nibName())
        self.tableview.dataSource = self
        self.tableview.delegate = self
        
        self.tableview.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        //To remove extra separators from tableview
        self.tableview.tableFooterView = UIView.init(frame: .zero)
    }
    
    func update(model: [SelectViewItemDataSourceProtocol], selectionType: SelectionType) {
        self.dataSource = model
        self.selectionType = selectionType
        self.tableview.isScrollEnabled = self.isScrollEnabled
        self.tableview.reloadData()
        self.tableview.layoutIfNeeded()
    }
    
    func getGetContentSizeHeight() -> CGFloat {
        return CGFloat(self.dataSource?.count ?? 0)  * SelectItemViewCell.cellHeight()
    }
    
    //MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: SelectItemViewCell.nibName(), for: indexPath) as! SelectItemViewCell
        if let dataSource = self.dataSource, indexPath.row < dataSource.count {
            cell.update(withModel: dataSource[indexPath.row])
        }
        cell.setSelectionType(type: self.selectionType)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectionType == .radio {
            var repeatedPressOnSameCell = false
            //reset state
            self.tableview.visibleCells.forEach { cell in
                if let cellIndexPath = self.tableview.indexPath(for: cell) {
                    if cellIndexPath.row != indexPath.row {
                        (cell as? SelectItemViewCell)?.setState(checked: false, animated: true)
                    } else if let dataSource = dataSource, dataSource.count > indexPath.row, let previousSelection = dataSource[indexPath.row].isSelected, previousSelection {
                        repeatedPressOnSameCell = true
                    }
                }
            }
            //if the user selected the same cell stop doing anything
            if repeatedPressOnSameCell { return }
            
            for i in 0 ..< (self.dataSource?.count ?? 0) {
                self.dataSource?[i].isSelected = false
            }
            self.toggleSelectOption(indexPath: indexPath)
        } else if selectionType == .checkbox {
            self.toggleSelectOption(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }
    
    internal func toggleSelectOption(indexPath: IndexPath) {
        if var dataSource = self.dataSource, indexPath.row < dataSource.count {
            dataSource[indexPath.row].isSelected?.toggle()
            if dataSource[indexPath.row].isSelected == nil {
                dataSource[indexPath.row].isSelected = true
            }
            (self.tableview.cellForRow(at: indexPath) as? SelectItemViewCell)?.toggle()
        }
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
