//
//  TileTeaserCollectionViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class TileTeaserCollectionViewCell: BaseCollectionViewCellSwift {

    @IBOutlet weak var image: UIImageView!
    
    var cellIndex: Int = 0 {
        didSet {
            self.image.backgroundColor = UIColor.placeholderColors[cellIndex % 6]
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        
        self.contentView.layer.cornerRadius = 2
        self.contentView.clipsToBounds = true
        
        self.clipsToBounds = false
        self.applyShadow(position: CGSize(width:0 , height: 1), color: .black, opacity: 0.2)

    }
}
