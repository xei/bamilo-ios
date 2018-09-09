//
//  RadioColoredButtonsGroupView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/6/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class RadioColoredButtonsGroupView: SelectView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableview.register(
            UINib(nibName: RadioColoredButtonItemTableViewCell.nibName(), bundle: nil),
            forCellReuseIdentifier: RadioColoredButtonItemTableViewCell.nibName()
        )
        self.selectionType = .radio
        self.isScrollEnabled = false
    }
    
    //doesn't matter what to pass as selection
    //type here because it should be radio type
    override func update(model: [SelectViewItemDataSourceProtocol], selectionType: SelectionType) {
        self.dataSource = model
        self.selectionType = .radio
        self.tableview.isScrollEnabled = self.isScrollEnabled
        self.tableview.reloadData()
        self.tableview.layoutIfNeeded()
        self.tableview.separatorStyle = .none
    }
    
    override func getGetContentSizeHeight() -> CGFloat {
        return CGFloat(self.dataSource?.count ?? 0) * 55.5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: RadioColoredButtonItemTableViewCell.nibName(), for: indexPath) as! RadioColoredButtonItemTableViewCell
        if let dataSource = self.dataSource, indexPath.row < dataSource.count {
            cell.progresIndex = Double(indexPath.row) / Double(dataSource.count - 1)
            cell.update(withModel: dataSource[indexPath.row])
        }
        return cell
    }
}
