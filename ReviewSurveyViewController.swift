//
//  ReviewSurveyViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/6/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import CHIPageControl

class ReviewSurveyViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak private var submitButton: OrangeButton!
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var pagerControl: CHIPageControlJaloro!
    
    var surverModel: ReviewSurvery!
    private var dataSource: [SurveyQuestion]?
    private var firstNotAnsweredQuestionIndex: Int = 3
    private var pagerMustBeUpdatedViaAnimation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyStyle()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.isPagingEnabled = true
        self.view.backgroundColor = .white
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        
        self.collectionView.register(UINib(nibName: SurveyQuestionCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: SurveyQuestionCollectionViewCell.nibName)
        
        self.updateView(by: surverModel)
    }

    private func applyStyle() {
        self.submitButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: .white)
        self.submitButton.setTitle(STRING_SUBMIT_LABEL, for: .normal)
        self.pagerControl.radius = 1
        self.pagerControl.tintColor = Theme.color(kColorGray9)
        self.pagerControl.currentPageTintColor = Theme.color(kColorOrange1)
        self.pagerControl.numberOfPages = 0
    }
    
    //MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let question = self.dataSource?[indexPath.row] {
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: SurveyQuestionCollectionViewCell.nibName, for: indexPath) as! SurveyQuestionCollectionViewCell
            cell.update(withModel: question)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pagerMustBeUpdatedViaAnimation = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pagerMustBeUpdatedViaAnimation = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Prevent user from scrolling to other more questions before answering this question
        if let x = self.collectionView.layoutAttributesForItem(at: IndexPath(row: firstNotAnsweredQuestionIndex + 1, section: 0))?.frame.maxX {
            if (scrollView.contentOffset.x < x) {
                scrollView.panGestureRecognizer.isEnabled = false
                scrollView.panGestureRecognizer.isEnabled = true
            }
        }
        self.updatePagerControl(animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.frame.size
    }
    
    private func updateView(by survey: ReviewSurvery) {
        self.dataSource = survey.page?.flatMap({ $0.questions }).flatMap({ $0 }).filter({ !$0.isHidden && $0.type != nil })
        self.pagerControl.numberOfPages = self.dataSource?.count ?? 0
        self.pagerControl.set(progress: self.pagerControl.numberOfPages - 1, animated: false)
        
        self.collectionView.reloadData()
    }
    
    private func updatePagerControl(animated: Bool) {
        let activeIndex = Int(ceil(self.collectionView.contentOffset.x / self.collectionView.frame.width))
        if self.pagerControl.currentPage != activeIndex {
            self.pagerControl.set(progress: activeIndex, animated: animated && pagerMustBeUpdatedViaAnimation)
        }
    }
    
    override func navBarTitleString() -> String! {
        return STRING_SURVEY
    }
    
    override func navBarleftButton() -> NavBarLeftButtonType {
        return .darkClose
    }
}
