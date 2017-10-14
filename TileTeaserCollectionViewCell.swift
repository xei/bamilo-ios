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
        
        self.layer.cornerRadius = 1
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 1
        self.layer.shadowOffset = CGSize(width:0 , height: 1)
        self.layer.borderWidth = 0
        self.clipsToBounds = false
    }
}
