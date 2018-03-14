//
//  SelectViewControl.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/12/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

enum SelectionType: String {
    case radio = "radio"
    case checkbox = "checkbox"
}

class SelectViewControl: BaseViewControl {
    
    var selectView: SelectView?
    var selectionType: SelectionType = .checkbox
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.selectView = SelectView.nibInstance()
        if let view = self.selectView {
            self.addAnchorMatchedSubView(view: view)
        }
    }
    
    override func update(withModel model: Any!) {
        if let model = model as? [SelectViewItemDataSourceProtocol] {
            self.selectView?.update(model: model, selectionType: selectionType)
        }
    }
}
