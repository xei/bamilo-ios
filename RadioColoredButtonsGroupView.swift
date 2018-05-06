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
        self.tableview.register(UINib(nibName: "", bundle: nil), forCellReuseIdentifier: "")
    }
}
