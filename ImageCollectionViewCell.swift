//
//  ImageCollectionViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/3/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

class ImageCollectionViewCell: BaseCollectionViewCellSwift {

    @IBOutlet private weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.clipsToBounds = true
        
        self.imageView.image = #imageLiteral(resourceName: "placeholder_gallery")
    }
    
    func update(imageUrl: URL) {
        self.imageView.kf.setImage(with: imageUrl, placeholder: #imageLiteral(resourceName: "placeholder_gallery"), options: [.transition(.fade(0.20))])
    }

    func setSelected(selected: Bool) {
        self.imageView.applyBorder(width: selected ? 1 : 0, color: Theme.color(kColorOrange1))
        self.contentView.applyShadow(position: CGSize(width:0 , height: 1), color: selected ? .black : .clear, opacity: 0.2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = #imageLiteral(resourceName: "placeholder_gallery")
    }
}
