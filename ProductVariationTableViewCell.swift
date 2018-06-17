//
//  ProductVariationTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/3/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit


protocol ProductVariationTableViewCellDelegate: class {
    func didSelectVariationSku(product: SimpleProduct)
}

class ProductVariationTableViewCell: BaseProductTableViewCell {
    
    @IBOutlet private weak var buttonSizesContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var buttonSizesContainerView: UIView!
    @IBOutlet private weak var sizeSelectionLabel: UILabel!
    @IBOutlet private weak var productSpecificationButton: UIButton!
    @IBOutlet private weak var descriptionButton: UIButton!
    @IBOutlet private weak var carouselCollectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var carouselToHorizontalSeperatorVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var carouselToSizeButtonsTitleLabelVerticalSpacingConstraint: NSLayoutConstraint!
    
    private var selectedSimple: SimpleProduct?
    private var product: Product?
    private let carouselCollectionFlowLayout = ProductVariationCarouselCollectionFlowLayout()
    private var gridButtons: [UIButton]?
    
    weak var delegate: ProductVariationTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
        
        titleLabel.text = STRING_SELECT_TYPE
        sizeSelectionLabel.text = STRING_SELECT_SIZE
        descriptionButton.setTitle(STRING_PRODUCT_DESCRIPTION, for: .normal)
        productSpecificationButton.setTitle(STRING_PRODUCT_SPECIFICATION, for: .normal)
        
        carouselCollectionView.backgroundColor = .clear
        carouselCollectionView.register(UINib(nibName: ImageCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: ImageCollectionViewCell.nibName)
        
        buttonSizesContainerView.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        carouselCollectionView.delegate = self
        carouselCollectionView.dataSource = self
    }
    
    func applyStyle() {
        [descriptionButton,  productSpecificationButton].forEach {$0.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorBlue)) }
        [titleLabel, sizeSelectionLabel].forEach{ $0.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1)) }
        self.carouselCollectionView.collectionViewLayout = carouselCollectionFlowLayout
        self.carouselCollectionView.backgroundColor = .clear
        self.carouselCollectionView.showsHorizontalScrollIndicator = false
    }
    
    override func update(withModel model: Any!) {
        if let product = model as? Product {
            self.product = product
            self.carouselCollectionView.reloadData()
            
            //Grid buttons
            if let avaiableVariations = self.product?.simpleVariationValues {
                
                self.sizeSelectionLabel.isHidden = false
                
                gridButtons = self.product?.simples?.filter { $0.variationValue != nil && avaiableVariations.contains($0.variationValue!)} .map { (simple) -> UIButton? in
                    if let title = simple.variationValue {
                        let button = createButton(withTitle: title)
                        button.transform = CGAffineTransform(scaleX: -1, y: 1)
                        button.isEnabled = simple.quantity > 0
                        return button
                    }
                    return nil
                    }.compactMap { $0 }
                if let buttons = gridButtons {
                    self.buttonSizesContainerViewHeightConstraint.constant = self.createButtonGridInView(parentView: buttonSizesContainerView, offset: 0, withButtons: buttons)
                    
                }
                
                self.sizeSelectionLabel.isHidden = avaiableVariations.count == 0
            }
        }
    }
    
}


extension ProductVariationTableViewCell {
    
    func createButton(withTitle title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.applyStyle(font: Theme.font(kFontVariationLight, size: 13), color: Theme.color(kColorGray1))
        button.setTitleColor(Theme.color(kColorGray8), for: .disabled)
        button.applyBorder(width: 1, color: Theme.color(kColorGray10))
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(gridButtonTapped(sender:)), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsetsMake(4.0, 10.0, 4.0, 10.0)
        button.sizeToFit()
        return button
    }
    
    @objc func gridButtonTapped(sender: UIButton) {
        gridButtons?.forEach {
            $0.backgroundColor = .white
            $0.setTitleColor(Theme.color(kColorGray1), for: .normal)
        }
        sender.backgroundColor = Theme.color(kColorBlue1)
        sender.setTitleColor(.white, for: .normal)
        
        if let title = sender.titleLabel?.text {
            selectedSimple = self.product?.simples?.filter { $0.variationValue == title }.first
        }
    }
    
    func createButtonGridInView(parentView: UIView, offset: Double = 5.0, spaceGap: Double = 5.0, withButtons buttons: [UIButton]) -> CGFloat {
        var x = 0.0, y = 0.0, row = 0.0
        // remove all subviews
        parentView.subviews.forEach { $0.removeFromSuperview() }
        var totalHeight: CGFloat = 0
        
        for idx in 0 ..< buttons.count {
            let button = buttons[idx]
            row += Double(button.frame.width) + spaceGap
            
            if row < Double(parentView.frame.width) {
                x = idx == 0 ? offset : row - Double(button.frame.width)
            } else {
                x = offset
                row = Double(button.frame.width) + offset
                y += Double(button.frame.height) + offset
            }
            
            let frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: button.frame.width, height: button.frame.height)
            button.frame = frame
            
            parentView.addSubview(button)
            totalHeight = frame.origin.y + frame.size.height
        }
        return totalHeight
    }
}



extension ProductVariationTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let variations = self.product?.variations, indexPath.row < variations.count {
            self.delegate?.didSelectVariationSku(product: variations[indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.carouselCollectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.nibName, for: indexPath) as! ImageCollectionViewCell
        if let variations = self.product?.variations, indexPath.row < variations.count, let variationUrl = variations[indexPath.row].image {
            cell.update(imageUrl: variationUrl)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.product?.variations?.count ?? 0
    }
}
