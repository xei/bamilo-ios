//
//  ProductEmptyReviewTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/28/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductEmptyReviewTableViewCell: BaseProductTableViewCell {

    weak var delegate: ProductDetailPrimaryInfoTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func rateButtonTapped(_ sender: Any) {
        delegate?.rateButtonTapped()
    }
}
