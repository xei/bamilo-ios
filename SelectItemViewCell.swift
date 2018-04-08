//
//  SelectItemViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/11/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import M13Checkbox

class SelectItemViewCell: BaseTableViewCell {
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var checkbox: M13Checkbox!
    private var model: SelectViewItemDataSourceProtocol?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyStyle()
    }
    
    func setSelectionType(type: SelectionType) {
        self.checkbox.boxType = type == .checkbox ? .square : .circle
        self.checkbox.markType = type == .checkbox ? .checkmark : .radio
    }
    
    func applyStyle() {
        self.titleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.checkbox.checkState = .unchecked
        self.checkbox.boxLineWidth = 2
        self.checkbox.checkmarkLineWidth = 2
        self.checkbox.stateChangeAnimation = .stroke
        self.checkbox.animationDuration = 0.25
        self.checkbox.markType = .checkmark
        self.checkbox.boxType = .square
        self.checkbox.tintColor = Theme.color(kColorOrange)
        self.checkbox.secondaryTintColor = Theme.color(kColorGray5)
        self.checkbox.isUserInteractionEnabled = false 
    }
    
    override func update(withModel model: Any!) {
        if let model = model as? SelectViewItemDataSourceProtocol {
            self.titleLabel.text = model.title
            self.setState(checked: model.isSelected ?? false)
            self.model = model
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func toggle() {
        ThreadManager.execute {
            self.checkbox.toggleCheckState(true)
        }
    }
    
    func setState(checked: Bool, animated: Bool = false) {
        ThreadManager.execute {
            self.checkbox.setCheckState(checked ? .checked : .unchecked, animated: animated)
        }
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
