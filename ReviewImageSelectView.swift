//
//  ReviewImageSelectView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/4/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

protocol ReviewImageSelectViewDelegate : class {
    func onFocus(refrence: ReviewImageSelectView)
}

class ReviewImageSelectView: BaseControlView, ReviewImageSelectItemViewDelegate {
    
    @IBOutlet weak private var verticalStackView: UIStackView!
    private var horizontalStackviews: [UIStackView] = []
    private var buttons: [ReviewImageSelectItemView]?
    private var lastTappedButton: ReviewImageSelectItemView?
    private var model: SurveyQuestion?
    weak var delegate: ReviewImageSelectViewDelegate?
    
    override func awakeFromNib() {
        verticalStackView.alignment = .center
        verticalStackView.distribution = .fillEqually
        verticalStackView.axis = .vertical
    }
    
    func update(model: SurveyQuestion) {
        if let options = model.options {
            fillStackView(by: convertToImageSelectItemView(options: options))
        }
        self.model = model
    }
    
    private func generateHorizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }
    
    private func fillStackView(by items: [ReviewImageSelectItemView]) {
        
        horizontalStackviews.removeAll()
        horizontalStackviews.append(self.generateHorizontalStackView())
        
        items.forEach { (item) in
            if self.horizontalStackviews.count == 0 { return }
            if horizontalStackviews[horizontalStackviews.count - 1].arrangedSubviews.count >= 3 {
                self.horizontalStackviews.append(self.generateHorizontalStackView())
            }
            self.horizontalStackviews[self.horizontalStackviews.count - 1].addArrangedSubview(item)
        }
        self.horizontalStackviews.forEach( { self.verticalStackView.addArrangedSubview($0) } )
    }
    
    private func convertToImageSelectItemView(options: [SurveyQuestionOption]) -> [ReviewImageSelectItemView] {
        let buttons = options.map({ (option) -> ReviewImageSelectItemView in
            let nibView = ReviewImageSelectItemView.nibInstance()
            nibView.update(model: option)
            nibView.delegate = self
            nibView.widthAnchor.constraint(equalToConstant: 100).isActive = true
            nibView.heightAnchor.constraint(equalToConstant: 90).isActive = true
            self.lastTappedButton = nil
            if let selected = option.isSelected, selected { self.lastTappedButton = nibView }
            return nibView
        })
        self.buttons = buttons
        return buttons
    }
    
    override static func nibInstance() -> ReviewImageSelectView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.last as! ReviewImageSelectView
    }
    
    //MARK: - ReviewImageSelectItemViewDelegate
    func tapped(item: ReviewImageSelectItemView) {
        if lastTappedButton == item { return }
        
        if lastTappedButton == nil { //it's first action of seletion
            buttons?.forEach({ if ($0 != item) { $0.setSelected(selected: false)} })
            self.delegate?.onFocus(refrence: self)
        }
        
        lastTappedButton?.setSelected(selected: false)
        lastTappedButton = item
    }
    
    func getSelectedOption() -> SurveyQuestionOption? {
        return self.lastTappedButton?.model
    }
}
