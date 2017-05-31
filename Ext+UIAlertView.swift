//
//  UIAlertView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

extension UIAlertController {
    
    private func changeFont(view:UIView,font:UIFont) {
        for item in view.subviews {
            if let col = item as? UICollectionView {
                for  row in col.subviews{
                    changeFont(view: row, font: font)
                }
            }
            if let label  = item as? UILabel {
                label.font = font
            } else {
                changeFont(view: item, font: font)
            }
            
        }
    }
    
    //To set font for any UILabels in action sheet
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let font = Theme.font(kFontVariationRegular, size: 15)
        changeFont(view: self.view, font: font! )
    }
}
