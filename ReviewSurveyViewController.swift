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
    private var firstNotAnsweredQuestionIndex: Int = 0
    private var pagerMustBeUpdatedViaAnimation: Bool = false
    private var activeIndex: Int = 0
    
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
    
    override func closeButtonTapped() {
        super.closeButtonTapped()
        
        //TODO: send dismiss message to server ignore survey
    }

    private func applyStyle() {
        self.submitButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: .white)
        self.submitButton.setTitle(STRING_NEXT, for: .normal)
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
        if scrollView == self.collectionView, let dataSource = self.dataSource, dataSource.count - 1 != self.firstNotAnsweredQuestionIndex {
            //Prevent user from scrolling to other more questions before answering this question
            if let x = self.collectionView.layoutAttributesForItem(at: IndexPath(row: self.firstNotAnsweredQuestionIndex, section: 0))?.frame.minX {
                if (scrollView.contentOffset.x < x) {
                    scrollView.panGestureRecognizer.isEnabled = false
                    scrollView.panGestureRecognizer.isEnabled = true
                }
            }
        }
        self.updateActiveIndexPath()
        self.updateSubmitButtonTitle()
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
        self.dataSource = survey.pages?.flatMap({ $0.questions }).flatMap({ $0 }).filter({ !$0.isHidden && $0.type != nil })
        self.pagerControl.numberOfPages = self.dataSource?.count ?? 0
        self.pagerControl.set(progress: self.pagerControl.numberOfPages - 1, animated: false)
        
        self.collectionView.reloadData()
    }
    
    private func updatePagerControl(animated: Bool) {
        if let dataSource = self.dataSource {
            if self.pagerControl.currentPage != dataSource.count - 1 - self.activeIndex {
                self.pagerControl.set(progress: dataSource.count - 1 - self.activeIndex, animated: animated && pagerMustBeUpdatedViaAnimation)
            }
        }
    }
    
    private func updateSubmitButtonTitle() {
        if let dataSource = self.dataSource, self.activeIndex == dataSource.count - 1 {
            self.submitButton.setTitle(STRING_SUBMIT_LABEL, for: .normal)
        } else {
            self.submitButton.setTitle(STRING_NEXT, for: .normal)
        }
    }
    
    
    private func updateActiveIndexPath() {
        let visibleRect = CGRect(origin: self.collectionView.contentOffset, size: self.collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = self.collectionView.indexPathForItem(at: visiblePoint) {
            self.activeIndex = visibleIndexPath.row
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        if let dataSource = self.dataSource {
            //TODO: submit the active question here
            if let activeQuestion = self.dataSource?[self.activeIndex] {
                self.submitQuestion(question: activeQuestion)
            }
            
            if self.firstNotAnsweredQuestionIndex >= self.activeIndex {
                if self.activeIndex < dataSource.count - 1 {
                    self.activeIndex += 1
                    self.scrollToIndex(index: self.activeIndex)
                } else {
                    //TODO: submit the last one
                }
            }
            if firstNotAnsweredQuestionIndex < activeIndex {
                firstNotAnsweredQuestionIndex = activeIndex
            }
        }
    }
    
    private func submitQuestion(question: SurveyQuestion) {
        //TODO: resubmit/submit question of survey
    }
    
    private func scrollToIndex(index: Int, animated: Bool? = true) {
        self.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
    override func navBarTitleString() -> String! {
        return STRING_SURVEY
    }
    
    override func navBarleftButton() -> NavBarLeftButtonType {
        return .darkClose
    }
}
