//
//  BreadcrumbsView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/22/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

protocol BreadcrumbsViewDelegate: class {
    func itemTapped(item: BreadcrumbsItem)
}

class BreadcrumbsView: BaseControlView {

    @IBOutlet weak private var scrollview: UIScrollView!
    private var breadcrumbs: [BreadcrumbsItem]?
    
    private lazy var buttons = [UIButton]()
    private lazy var arrowImageViews = [UIImageView]()
    var isCategoryThemplate = false
    weak var delegate: BreadcrumbsViewDelegate?
    
    override func awakeFromNib() {
        self.backgroundColor = .clear
        self.scrollview.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.scrollview.backgroundColor = .clear
        self.scrollview.alwaysBounceHorizontal = true
        self.scrollview.alwaysBounceVertical = false
        self.scrollview.showsHorizontalScrollIndicator = false
        self.scrollview.showsVerticalScrollIndicator = false
    }
    
    var contentHeight: CGFloat = 46
    var buttonTitleFont = Theme.font(kFontVariationRegular, size: 12)
    var buttonTitleColor = Theme.color(kColorBlue1)
    var buttonBackgroundColor = Theme.color(kColorBlue10)
    var buttonTitleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    var buttonVerticalMargin: CGFloat = 8
    var buttonHorizontalMargin: CGFloat = 2
    var buttonHorizontalPadding: CGFloat = 8
    var imageHorizontalMargin: CGFloat = 0
    var imageSize = CGSize(width: 15, height: 15)
    var buttonBorderRadius: CGFloat = 15
    var wholeContentMargin: CGFloat = 16
    
    private func createButton(item: BreadcrumbsItem) -> UIButton {
        let button = UIButton(type: .custom) as UIButton
        button.titleLabel?.font = self.buttonTitleFont
        button.setTitleColor(buttonTitleColor, for: .normal)
        button.titleEdgeInsets = self.buttonTitleEdgeInsets
        button.setTitle(item.title, for: .normal)
        button.backgroundColor = self.buttonBackgroundColor
        button.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        button.titleLabel?.sizeToFit()
        button.sizeToFit()
        
        button.frame = CGRect(origin: .zero, size: CGSize(width: button.frame.width + buttonHorizontalPadding * 2, height: self.contentHeight - self.buttonVerticalMargin * 2))
        button.clipsToBounds = true
        button.layer.cornerRadius = self.buttonBorderRadius
        button.addTarget(self, action: #selector(self.touchUpInsideButton), for: .touchUpInside)
        
        return button
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        var offset:CGFloat = 0
        if self.buttons.count == 0 { return }
        for (index, button) in self.buttons.enumerated() {
            let imageWidthAndAllMargins = offset == 0 ? buttonHorizontalMargin : buttonHorizontalMargin + imageHorizontalMargin * 2 + imageSize.width
            button.frame.origin.x = imageWidthAndAllMargins + offset
            button.center.y = self.contentHeight / 2
            if index < self.arrowImageViews.count {
                self.arrowImageViews[index].frame = CGRect(origin: CGPoint(x: button.frame.maxX + buttonHorizontalMargin + imageHorizontalMargin, y: self.scrollview.center.y), size: imageSize)
                self.arrowImageViews[index].center.y = self.contentHeight / 2
            }
            offset += button.frame.width + imageWidthAndAllMargins
        }
        let imageWidthAndHorizontalMargins = imageHorizontalMargin * 2 + imageSize.width
        let contentSize = offset > 0 ?  offset - imageWidthAndHorizontalMargins + wholeContentMargin + buttonHorizontalMargin : offset
        let contentHorizontalMargin = wholeContentMargin - buttonHorizontalMargin
        self.scrollview.contentInset = UIEdgeInsetsMake(0, contentHorizontalMargin, 0, contentHorizontalMargin)
        self.scrollview.contentSize = CGSize(width: contentSize, height: self.contentHeight)
    }
    
    @objc private func touchUpInsideButton(sender: UIButton!) {
        if let items = self.breadcrumbs, let index = items.index(where: {sender.titleLabel != nil && $0.title == sender.titleLabel?.text }), index < items.count {
            self.delegate?.itemTapped(item: items[index])
        }
    }
    
    func update(model: [BreadcrumbsItem]) {
        self.resetAndClear()
        for (index, item) in model.enumerated() {
            let btn = self.createButton(item: item)
            self.scrollview.insertSubview(btn, at: 0)
            btn.layoutIfNeeded()
            self.buttons.append(btn)
            if index != model.count - 1 {
                //Is not last item
                if let arrowImage = UIImage(named: "ArrowLeft") {
                    let imageView = UIImageView(image: arrowImage)
                    imageView.tintColor = Theme.color(kColorBlue)
                    imageView.contentMode = .scaleAspectFit
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                    self.arrowImageViews.append(imageView)
                    self.scrollview.insertSubview(imageView, at: 0)
                }
            }
        }
        self.breadcrumbs = model
        self.layoutIfNeeded()
    }
    
    func resetAndClear() {
        self.buttons.forEach { (button) in
            button.removeFromSuperview()
        }
        self.buttons.removeAll()
        self.arrowImageViews.forEach { (image) in
            image.removeFromSuperview()
        }
        self.arrowImageViews.removeAll()
    }
    
    //TODO: when we migrate all BaseControlView we need to use it as this function implementation
    override class func nibInstance() -> BreadcrumbsView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.last as! BreadcrumbsView
    }
}
