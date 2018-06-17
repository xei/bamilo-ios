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
        self.imageView.image = #imageLiteral(resourceName: "placeholder_gallery")
    }
    
    func update(imageUrl: URL) {
        self.imageView.kf.setImage(with: imageUrl, placeholder: #imageLiteral(resourceName: "placeholder_gallery"), options: [.transition(.fade(0.20))])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = #imageLiteral(resourceName: "placeholder_gallery")
    }
}
