//
//  ProductSpecificsTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/25/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

protocol ProductSpecificsTableViewCellDelegate: class {
    func seeMoreInfoTapped(cell: ProductSpecificsTableViewCell, indexPath: IndexPath)
}

class ProductSpecificsTableViewCell: BaseProductTableViewCell {

    @IBOutlet private weak var contetntLabel: UILabel!
    @IBOutlet private weak var seperatorView: UIView!
    @IBOutlet private weak var moreInfoButton: UIButton!
    weak var delegate: ProductSpecificsTableViewCellDelegate?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
    }

    func applyStyle() {
        seperatorView.backgroundColor = Theme.color(kColorGray10)
        contetntLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 11), color: Theme.color(kColorGray1))
        moreInfoButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorBlue))
    }
    
    override func update(withModel model: Any!) {
        if let description = model as? String {

            self.contetntLabel.text = description
            self.moreInfoButton.setTitle(STRING_WHOLE_DESCRIPTION, for: .normal)
            
        } else if let specifics = model as? [productSpecificsTableSection] {
            self.moreInfoButton.setTitle(STRING_WHOLE_SPECIFICATIONS, for: .normal)
            
            //print only first sepecification as summery
            self.contetntLabel.text = specifics.first?.body?.reduce("", { (accumulator, specific) -> String in
                if let key = specific.title, let value = specific.value {
                    return "\(accumulator) - \(key): \(value) \n"
                }
                return accumulator
            })
        }
    }
    
    
    @IBAction func moreInfoButtonTapped(_ sender: Any) {
        if let indexPath = indexPath {
            self.delegate?.seeMoreInfoTapped(cell: self, indexPath: indexPath)
        }
    }
}
