//
//  LoadingCoverView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 12/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class LoadingCoverView: BaseControlView {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.loadingIndicator.startAnimating()
        self.containerView.backgroundColor = Theme.color(kColorBlue6)
        self.containerView.alpha = 0.8
        self.backgroundView.backgroundColor = .white
        self.backgroundView.alpha = 0.7
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
