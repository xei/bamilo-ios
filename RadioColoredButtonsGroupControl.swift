//
//  RadioColoredButtonsGroupControl.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/7/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class RadioColoredButtonsGroupControl: BaseViewControl {

    var radioButtonGroupView: RadioColoredButtonsGroupView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.radioButtonGroupView = RadioColoredButtonsGroupView.nibInstance()
        if let view = self.radioButtonGroupView {
            self.addAnchorMatchedSubView(view: view)
        }
    }
    
    func getGetContentSizeHeight() -> CGFloat {
        return self.radioButtonGroupView?.getGetContentSizeHeight() ?? 0
    }
    
    override func update(withModel model: Any!) {
        if let model = model as? [SelectViewItemDataSourceProtocol] {
            self.radioButtonGroupView?.update(model: model, selectionType: .radio)
        }
    }

}
