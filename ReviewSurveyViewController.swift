//
//  ReviewSurveyViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/6/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout

class ReviewSurveyViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DataServiceProtocol {

    @IBOutlet weak private var submitButton: OrangeButton!
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var submitButtonHightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var pagerControl: CHIPageControlJaloro!
    @IBOutlet weak private var submitButtonBottomConstraint: NSLayoutConstraint!
    
    var surveryModel: ReviewSurvery!
    var orderID: String!
    
    private var dataSource: [SurveyQuestion]?
    private var firstNotAnsweredQuestionIndex: Int = 0
    private var pagerMustBeUpdatedViaAnimation: Bool = false
    private let pagerHorizontalPadding: CGFloat = 7
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
        
        self.collectionView.isPagingEnabled = true
        
        if let layout = collectionView?.collectionViewLayout as? AnimatedCollectionViewLayout {
            layout.scrollDirection = .horizontal
            layout.animator = CubeAttributesAnimator()
        }
        
        self.collectionView.register(UINib(nibName: SurveyQuestionCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: SurveyQuestionCollectionViewCell.nibName)
        self.collectionView.register(UINib(nibName: AppreciateSurveyCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: AppreciateSurveyCollectionViewCell.nibName)

        self.updateView(by: surveryModel)
        self.title = self.surveryModel.title ?? STRING_SURVEY
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: Theme.font(kFontVariationBold, size: 14),
            NSAttributedStringKey.foregroundColor: Theme.color(kColorBlue2)
            ] as [NSAttributedStringKey : Any]
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.collectionView.contentInset.bottom = self.submitButtonHightConstraint.constant + 15
        
        submitButton.applyGradient(colours: [
            UIColor(red:1, green:0.65, blue:0.05, alpha:1),
            UIColor(red:0.97, green:0.42, blue:0.11, alpha:1)
        ])
        submitButton.layer.cornerRadius = submitButtonHightConstraint.constant / 2
        submitButton.clipsToBounds = true
    }
    
    deinit {
        //remove all observers for this view controller when it's deinitliazed
        NotificationCenter.default.removeObserver(self)
    }
    
    override func closeButtonTapped() {
        if let id = self.surveryModel.id, let dataSource = self.dataSource, self.activeIndex != dataSource.count {
            ReviewServiceDataManager.sharedInstance.ignoreSurvey(self, surveyID: "\(id)") { (data, error) in }
        }
        super.closeButtonTapped()
    }

    private func applyStyle() {
        self.submitButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: .white)
        self.submitButton.setTitle(STRING_NEXT, for: .normal)
        self.pagerControl.radius = 4
        self.pagerControl.tintColor = Theme.color(kColorGray9)
        self.pagerControl.currentPageTintColor = Theme.color(kColorOrange)
        self.pagerControl.numberOfPages = 0
        self.pagerControl.elementHeight = 9
        
        //for RTL view
        self.pagerControl.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
    
    //MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    var mycell: UICollectionViewCell?
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let dataSource = self.dataSource, indexPath.row < dataSource.count {
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: SurveyQuestionCollectionViewCell.nibName, for: indexPath) as! SurveyQuestionCollectionViewCell
            self.mycell = cell
            cell.update(withModel: dataSource[indexPath.row])
            return cell
        } else {
            return self.collectionView.dequeueReusableCell(withReuseIdentifier: AppreciateSurveyCollectionViewCell.nibName, for: indexPath) as! AppreciateSurveyCollectionViewCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (dataSource?.count ?? 0) + 1
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pagerMustBeUpdatedViaAnimation = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pagerMustBeUpdatedViaAnimation = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView, let dataSource = self.dataSource, dataSource.count != self.firstNotAnsweredQuestionIndex {
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
        return CGSize(width: self.collectionView.frame.size.width, height: self.collectionView.frame.size.height - self.submitButtonHightConstraint.constant - 15)
    }
    
    private func updateView(by survey: ReviewSurvery) {
        self.dataSource = survey.pages?.compactMap({ $0.questions }).flatMap({ $0 }).filter({ !$0.isHidden && $0.type != nil })
        if let dataSourceCount = self.dataSource?.count, dataSourceCount > 1 {
            self.pagerControl.numberOfPages = dataSourceCount + 1
        } else {
            self.pagerControl.isHidden = true
        }
        self.pagerControl.elementWidth = UIScreen.main.bounds.width / CGFloat(self.pagerControl.numberOfPages) - 2 * self.pagerHorizontalPadding
        self.collectionView.reloadData()
    }
    
    private func updatePagerControl(animated: Bool) {
        if self.pagerControl.currentPage != self.activeIndex {
            self.pagerControl.set(progress: self.activeIndex, animated: animated && pagerMustBeUpdatedViaAnimation)
        }
    }
    
    private func updateSubmitButtonTitle() {
        if let dataSource = self.dataSource, self.activeIndex == dataSource.count - 1 {
            self.submitButton.setTitle(STRING_SUBMIT_LABEL, for: .normal)
        } else if let dataSource = self.dataSource, self.activeIndex == dataSource.count {
            self.submitButton.setTitle(STRING_CLOSE, for: .normal)
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
        self.view.endEditing(true)
        if let dataSource = self.dataSource {
            
            //last view is appreciation view
            if dataSource.count == self.activeIndex {
                self.dismiss(animated: true, completion: nil)
            }
            
            if let dataSource = self.dataSource, dataSource.count > self.activeIndex {
                self.submitQuestion(question: dataSource[self.activeIndex], isLastOne: dataSource.count - 1 == self.activeIndex)
            }
            if self.firstNotAnsweredQuestionIndex >= self.activeIndex {
                if self.activeIndex < dataSource.count {
                    self.activeIndex += 1
                    Utility.delay(duration: 0.15) {
                        self.scrollToIndex(index: self.activeIndex)
                    }
                }
            }
            if firstNotAnsweredQuestionIndex < activeIndex {
                firstNotAnsweredQuestionIndex = activeIndex
            }
        }
    }
    
    private func submitQuestion(question: SurveyQuestion, isLastOne: Bool) {
        
        if let activeQuestionOptionsCount = question.options?.filter({ $0.isSelected ?? false }).count, activeQuestionOptionsCount > 0 , let alias = self.surveryModel.alias {
                ReviewServiceDataManager.sharedInstance.sendSurveyAlias(self, surveyAlias: alias, question: question, isLastOne: isLastOne, for: self.orderID, requestType: .background) { data, error in
                }
        } else if let _ = question.anwerTextMessage, let alias = self.surveryModel.alias {
            ReviewServiceDataManager.sharedInstance.sendSurveyAlias(self, surveyAlias: alias, question: question, isLastOne: isLastOne, for: self.orderID, requestType: .background) { data, error in
            }
        }
        
        if isLastOne {
            self.collectionView.isScrollEnabled = false
            Utility.delay(duration: 4) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func scrollToIndex(index: Int, animated: Bool? = true) {
        self.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
    override func navBarTitleString() -> String! {
        return STRING_SURVEY
    }
    
    override func navBarRightButton() -> NavBarButtonType {
        return .darkClose
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        
    }
    
    
    //MARK: - KeyboardNotifications
    @objc func keyboardWasShown(notification:NSNotification) {
        let userInfo = notification.userInfo
        let keyboardFrame: NSValue? = userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        let keyboardRectangle = keyboardFrame?.cgRectValue
        if let keyboardHeight = keyboardRectangle?.height {
            self.submitButtonBottomConstraint.constant = keyboardHeight
            self.collectionView.collectionViewLayout.invalidateLayout()
            
            self.collectionView.panGestureRecognizer.isEnabled = false
        }
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        self.submitButtonBottomConstraint.constant = 0
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.panGestureRecognizer.isEnabled = true
    }
}
