//
//  RadioColoredButtonItemTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/6/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class RadioColoredButtonItemTableViewCell: SelectItemViewCell {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var greenBackgroundView: UIView!
    @IBOutlet weak var redBackgroundView: UIView!
    
    var progresIndex: Double = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.button.backgroundColor = .clear
        self.button.setTitleColor(.white, for: .normal)
        self.greenBackgroundView.backgroundColor = Theme.color(kColorGreen1)
        self.redBackgroundView.backgroundColor = Theme.color(kColorRed)
    }
    
    override func update(withModel model: Any!) {
        if let model = model as? SelectViewItemDataSourceProtocol {
            self.button.setTitle(model.title ?? "", for: .normal)
            self.redBackgroundView.alpha = CGFloat(progresIndex)
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.15) {
                
            }
        } else {
            
        }
    }
}
