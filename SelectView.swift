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
    
    @IBOutlet weak private var tableview: UITableView!
    private var selectionType: SelectionType = .checkbox
    private var dataSource: [SelectViewItemDataSourceProtocol]?
    private var radioTypePreviousSelectionIndexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableview.register(UINib(nibName: SelectItemViewCell.nibName(), bundle: nil), forCellReuseIdentifier: SelectItemViewCell.nibName())
        self.tableview.dataSource = self
        self.tableview.delegate = self
        
        //To remove extra separators from tableview
        self.tableview.tableFooterView = UIView.init(frame: .zero)
    }
    
    func update(model: [SelectViewItemDataSourceProtocol], selectionType: SelectionType) {
        self.dataSource = model
        self.selectionType = selectionType
        self.tableview.reloadData()
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
        if selectionType == .radio, radioTypePreviousSelectionIndexPath != indexPath {
            if let previousIndexPath = radioTypePreviousSelectionIndexPath {
                self.toggleSelectOption(indexPath: previousIndexPath)
            }
            radioTypePreviousSelectionIndexPath = indexPath
            self.toggleSelectOption(indexPath: indexPath)
        } else if selectionType == .checkbox {
            self.toggleSelectOption(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }
    
    private func toggleSelectOption(indexPath: IndexPath) {
        if var dataSource = self.dataSource, indexPath.row < dataSource.count {
            dataSource[indexPath.row].isSelected?.toggle()
            (self.tableview.cellForRow(at: indexPath) as? SelectItemViewCell)?.toggle()
        }
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
