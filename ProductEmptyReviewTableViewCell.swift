//
//  ProductEmptyReviewTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/28/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductEmptyReviewTableViewCell: BaseProductTableViewCell {
    
    @IBOutlet private var leftArrowImageView: UIImageView!
    weak var delegate: ProductDetailPrimaryInfoTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        leftArrowImageView.image = #imageLiteral(resourceName: "ArrowLeft").withRenderingMode(.alwaysTemplate)
        leftArrowImageView.tintColor = Theme.color(kColorGray5)
    }
    
    @IBAction func rateButtonTapped(_ sender: Any) {
        delegate?.rateButtonTapped()
    }
}
