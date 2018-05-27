//
//  MyBamiloHeaderView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

protocol MyBamiloHeaderViewDelegate: class {
    func menuButtonTapped()
}

class MyBamiloHeaderView: UICollectionReusableView {

    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var menuButton: UIButton!
    weak var delegate: MyBamiloHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.menuButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.menuButton.titleLabel?.textAlignment = .center
        self.menuButton.setTitle(STRING_ALL_CATEGORIES, for: .normal)
        self.menuButton.backgroundColor = .white
        
        self.menuButton.layer.cornerRadius = 3
        self.menuButton.clipsToBounds = true
        
        self.containerView.applyShadow(position: CGSize(width:0 , height: 1), color: .black, opacity: 0.2)
        
        self.clipsToBounds = false
        self.backgroundColor = .clear
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        self.delegate?.menuButtonTapped()
    }
    
    func setTitle(title: String) {
        self.menuButton.setTitle(title, for: .normal)
    }
    
    
    class func nibName() -> String {
        return "MyBamiloHeaderView"
    }
}
