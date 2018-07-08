//
//  ProductReviewSummeryTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/1/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit


protocol ProductReviewSummeryTableViewCellDelegate: class {
    func reviewItemSeeMoreButtonTapped(review: ProductReviewItem)
    func seeAllCommentButttonTapped()
    func writeCommentButtonTapped()
}

class ProductReviewSummeryTableViewCell: BaseProductTableViewCell {

    @IBOutlet private weak var averageRateLabel: UILabel!
    @IBOutlet private weak var baseAverageRateLabel: UILabel!
    @IBOutlet private weak var rateCountLabel: UILabel!
    @IBOutlet private weak var writeCommentButton: UIButton!
    @IBOutlet private weak var seperatorView: UIView!
    @IBOutlet private weak var reviewCollectionView: UICollectionView!
    @IBOutlet private weak var moreCommentsButton: UIButton!
    @IBOutlet private weak var moreCommentButtonHeightConstraint: NSLayoutConstraint!
    
    var model: Product?
    weak var delegate: ProductReviewSummeryTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
        
        reviewCollectionView.register(UINib(nibName: ProductReviewCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: ProductReviewCollectionViewCell.nibName)
        reviewCollectionView.showsHorizontalScrollIndicator = false
        reviewCollectionView.clipsToBounds = false
        reviewCollectionView.collectionViewLayout = ProductReviewCarouselCollectionFlowLayout()
        reviewCollectionView.delegate = self
        reviewCollectionView.dataSource = self
        
        writeCommentButton.setTitle(STRING_WRITE_COMMENT, for: .normal)
        moreCommentsButton.setTitle(STRING_SEE_ALL_COMMENTS, for: .normal)
    }
    
    @IBAction func seeAllCommentsTapped(_ sender: Any) {
        delegate?.seeAllCommentButttonTapped()
    }
    
    @IBAction func writeCommentButtonTapped(_ sender: Any) {
        delegate?.writeCommentButtonTapped()
    }
    
    
    func applyStyle(){
        averageRateLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 48), color: Theme.color(kColorGray1))
        baseAverageRateLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 14), color: Theme.color(kColorGray8))
        rateCountLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 14), color: Theme.color(kColorGray1))
        [writeCommentButton, moreCommentsButton].forEach{$0.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorBlue))}
        seperatorView.backgroundColor = Theme.color(kColorGray10)
    }
    
    override func update(withModel model: Any!) {
        if let product = model as? Product {
            self.model = product
            averageRateLabel.text = Utility.formatScoreValue(score: product.ratings?.average ?? 0)
            baseAverageRateLabel.text = "\(STRING_FROM) \(Utility.formatScoreValue(score: product.ratings?.maxValue ?? 0))"
            rateCountLabel.text = "\(product.ratings?.totalCount ?? 0) \(STRING_COMMENT)".convertTo(language: .arabic)
            reviewCollectionView.reloadData()
            moreCommentButtonHeightConstraint.constant = (product.reviews?.totalCount ?? 0) == 0 ? 0 :47
            moreCommentsButton.isHidden = (product.reviews?.totalCount ?? 0) == 0
        }
    }
}

extension ProductReviewSummeryTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = reviewCollectionView.dequeueReusableCell(withReuseIdentifier: ProductReviewCollectionViewCell.nibName, for: indexPath) as! ProductReviewCollectionViewCell
        if let reviewItems = model?.reviews?.items, indexPath.row < reviewItems.count {
            cell.update(withModel: reviewItems[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.reviews?.items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let reviewItems = model?.reviews?.items, indexPath.row < reviewItems.count {
            delegate?.reviewItemSeeMoreButtonTapped(review: reviewItems[indexPath.row])
        }
    }
}
