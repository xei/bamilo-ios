//
//  IconTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class IconTableViewCell: BaseTableViewCell {
    

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    private func setupView() {
        self.titleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray3))
        self.cellImageView.image = #imageLiteral(resourceName: "placeholder_list")
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
    override func prepareForReuse() {
        self.cellImageView.image = #imageLiteral(resourceName: "placeholder_list")
        self.titleLabel.text = nil
    }
}
