//
//  ProductVariationView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/18/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

protocol ProductVariationViewDelegate: class {
    func didSelectVariationSku(product: SimpleProduct)
    func didSelectSimpleSku(product: SimpleProduct)
}

class ProductVariationView: BaseControlView {
    
    weak var delegate: ProductVariationViewDelegate?
    @IBOutlet private weak var buttonSizesContainerView: UIView!
    @IBOutlet private weak var sizeSelectionLabel: UILabel!
    @IBOutlet private weak var carouselCollectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var buttonSizesContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var variationTopTitleToSuperviewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var variationCarouselBottomToSuperViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var variationCarouselBottomToTopSuperViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sizeGridButtonsBottomToSuperviewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sizeGridButtonBottomToSuperviewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonSizeTopToSuperviewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var variationContainerView: UIView!
    @IBOutlet private weak var sizesContainerView: UIView!
    
    var selectedSimple: SimpleProduct?
    private var product: Product?
    private let carouselCollectionFlowLayout = ProductVariationCarouselCollectionFlowLayout()
    private var gridButtons: [UIButton]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
        [variationContainerView ,sizesContainerView, buttonSizesContainerView].forEach { $0?.backgroundColor = .clear }
        titleLabel.text = STRING_SELECT_TYPE
        sizeSelectionLabel.text = STRING_SELECT_SIZE
        
        carouselCollectionView.backgroundColor = .clear
        carouselCollectionView.register(UINib(nibName: ImageCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: ImageCollectionViewCell.nibName)
        
        buttonSizesContainerView.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        carouselCollectionView.clipsToBounds = false
        carouselCollectionView.delegate = self
        carouselCollectionView.dataSource = self
    }
    
    func applyStyle() {
        self.backgroundColor = .clear
        [titleLabel, sizeSelectionLabel].forEach{ $0.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1)) }
        self.carouselCollectionView.collectionViewLayout = carouselCollectionFlowLayout
        self.carouselCollectionView.backgroundColor = .clear
        self.carouselCollectionView.showsHorizontalScrollIndicator = false
    }
    
    func update(product: Product) {
        self.product = product
        
        //variation type section
        self.carouselCollectionView.reloadData()
        if let variations = self.product?.variations {
            setProductVariation(visible: variations.count > 1)
        } else {
            setProductVariation(visible: false)
        }
        
        //(size)Grid buttons
        gridButtons = self.product?.presentableSimples?.map { (simple) -> UIButton? in
            if let title = simple.variationValue {
                let button = createButton(withTitle: title, selected: simple.isSelected)
                button.transform = CGAffineTransform(scaleX: -1, y: 1)
                button.isEnabled = simple.quantity > 0
                return button
            }
            return nil
            }.compactMap { $0 }
        if let buttons = gridButtons {
            if buttons.count > 0 {
                self.buttonSizesContainerViewHeightConstraint.constant = self.createButtonGridInView(parentView: buttonSizesContainerView, offset: 0, withButtons: buttons)
                setProductSimples(visible: true)
                return
            }
        }
        setProductSimples(visible: false)
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
    
    //MARK: ----- helpers-----
    private func setProductVariation(visible: Bool) {
        variationCarouselBottomToSuperViewBottomConstraint.priority = visible ? .defaultHigh : .defaultLow
        variationCarouselBottomToTopSuperViewConstraint.priority = !visible ? .defaultHigh : .defaultLow
        variationTopTitleToSuperviewTopConstraint.priority = visible ? .defaultHigh : .defaultLow
        
        //make a gap for second part of view's title
        buttonSizeTopToSuperviewTopConstraint.constant = variationTopTitleToSuperviewTopConstraint.constant
    }
    
    
    private func setProductSimples(visible: Bool) {
        sizeGridButtonsBottomToSuperviewBottomConstraint.priority = visible ? .defaultHigh : .defaultLow
        sizeGridButtonBottomToSuperviewTopConstraint.priority = !visible ? .defaultHigh : .defaultLow
        buttonSizeTopToSuperviewTopConstraint.priority = visible ? .defaultHigh : .defaultLow
    }
    
}


extension ProductVariationView {
    
    func createButton(withTitle title: String, selected: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.applyStyle(font: Theme.font(kFontVariationLight, size: 13), color: Theme.color(kColorGray1))
        button.setTitleColor(Theme.color(kColorGray10), for: .disabled)
        button.setTitleColor(selected ? .white : Theme.color(kColorGray1), for: .normal)
        button.applyBorder(width: 1, color: Theme.color(kColorGray10))
        button.layer.cornerRadius = 20
        button.backgroundColor = selected ? Theme.color(kColorBlue1) : .white
        button.addTarget(self, action: #selector(gridButtonTapped(sender:)), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsetsMake(8.0, 15.0, 8.0, 15.0)
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
            self.product?.simples?.forEach { $0.isSelected = false }
            selectedSimple = self.product?.simples?.filter { $0.variationValue == title }.first
            selectedSimple?.isSelected = true
            if let simple = selectedSimple {
                self.delegate?.didSelectSimpleSku(product: simple)
            }
        }
    }
    
    func createButtonGridInView(parentView: UIView, offset: Double = 5.0, spaceGap: Double = 5.0, withButtons buttons: [UIButton]) -> CGFloat {
        var x = 0.0, y = 0.0, row = 0.0
        // remove all subviews
        parentView.subviews.forEach { $0.removeFromSuperview() }
        var totalHeight: CGFloat = 0
        
        for idx in 0 ..< buttons.count {
            let button = buttons[idx]
            row += Double(button.frame.width) + (idx == 1 ? offset : spaceGap)
            
            if row < Double(parentView.frame.width) {
                x = idx == 0 ? offset : row - Double(button.frame.width)
            } else {
                x = offset
                row = Double(button.frame.width) + offset
                y += Double(button.frame.height) + spaceGap
            }
            
            let frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: button.frame.width, height: button.frame.height)
            button.frame = frame
            
            parentView.addSubview(button)
            totalHeight = frame.origin.y + frame.size.height
        }
        return totalHeight
    }
}



extension ProductVariationView: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
            
            //selected state for first cell
            if let sku = self.product?.sku {
                cell.setSelected(selected: variations[indexPath.row].sku == sku)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.product?.variations?.count ?? 0
    }
    
}
