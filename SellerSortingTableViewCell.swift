//
//  SellerSortingTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/24/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

protocol SellerSortingTableViewCellDelegate {
    func updateWithSortingMethod(method: SellerSortingMethod)
}

enum SellerSortingMethod {
    case time
    case price
    case score
}

class SellerSortingTableViewCell: BaseTableViewCell {

    @IBOutlet weak var scoreButton: UIButton!
    @IBOutlet weak var timeSortButton: UIButton!
    @IBOutlet weak var priceSortButton: UIButton!
    var delegate: SellerSortingTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        [timeSortButton, priceSortButton, scoreButton].forEach {
            $0?.setBackgroundImage(nil, for: .normal)
            $0?.setImage(nil, for: .normal)
            $0?.setBackgroundImage(nil, for: .selected)
            $0?.setImage(nil, for: .selected)
            $0?.backgroundColor = .clear
        }
    }

    @IBAction func priceSortingButtonTapped(_ sender: UIButton) {
        updateUIFor(method: .price)
        delegate?.updateWithSortingMethod(method: .price)
    }
    
    @IBAction func timeSortingButtonTapped(_ sender: UIButton) {
        updateUIFor(method: .time)
        delegate?.updateWithSortingMethod(method: .time)
    }
    
    @IBAction func scoreButtonTapped(_ sender: Any) {
        updateUIFor(method: .score)
        delegate?.updateWithSortingMethod(method: .score)
    }
    
    func updateUIFor(method: SellerSortingMethod) {
        
        timeSortButton.backgroundColor = method == .time ? timeSortButton.titleColor(for: .normal) : .clear
        timeSortButton.isSelected = method == .time
        
        priceSortButton.backgroundColor = method == .price ? priceSortButton.titleColor(for: .normal) : .clear
        priceSortButton.isSelected = method == .price
        
        scoreButton.backgroundColor = method == .score ? priceSortButton.titleColor(for: .normal) : .clear
        scoreButton.isSelected = method == .score
        
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
