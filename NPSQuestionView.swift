//
//  NPSQuestionView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/10/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

class NPSQuestionView: BaseSurveyQuestionControlView, HorizontalPickerViewDelegate, HorizontalPickerViewDataSource {

    @IBOutlet weak private var questionTitle: UILabel!
    @IBOutlet weak private var optionImageView: UIImageView!
    @IBOutlet weak private var horizontalPickerView: HorizontalPickerView!
    private var previousQuestionOption: SurveyQuestionOption?
    
    override func update(model: SurveyQuestion) {
        super.update(model: model)
        self.questionTitle.text = self.questionModel?.title
        self.horizontalPickerView.reloadAll()
        self.horizontalPickerView.tintColor = UIColor.red
        
        //Do after horizontalPicker updated
        if let options = self.questionModel?.options {
            let selectedIndex = options.index(where: { $0.isSelected ?? false }) ?? options.count / 2
            ThreadManager.execute {
                self.horizontalPickerView.selectRow(rowIndex: selectedIndex, animated: false)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.horizontalPickerView.delegate = self
        self.horizontalPickerView.dataSource = self
    }
    
    override static func nibInstance() -> NPSQuestionView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.last as! NPSQuestionView
    }
    
    //MARK: - HorizontalPickerViewDataSource - HorizontalPickerViewDelegate
    func numberOfRowsInHorizontalPickerView(pickerView: HorizontalPickerView) -> Int {
        return questionModel?.options?.count ?? 0
    }
    
    func horizontalPickerView(pickerView: HorizontalPickerView, titleForRow row: Int) -> String {
        if let options = questionModel?.options, row < options.count {
            return options[row].title?.convertTo(language: .arabic) ?? ""
        }
        return ""
    }
    
    func horizontalPickerView(pickerView: HorizontalPickerView, didSelectRow row: Int) {
        if let selectedOption = self.questionModel?.options?[row] {
            selectedOption.isSelected = true
            self.optionImageView.kf.setImage(with: selectedOption.image, options: [.transition(.fade(0.20))])
            self.previousQuestionOption?.isSelected = false
            self.previousQuestionOption = selectedOption
        }
    }
    
    func textColorForHorizontalPickerView(pickerView: HorizontalPickerView) -> UIColor {
        return UIColor.lightGray
    }
    
    func textFontForHorizontalPickerView(pickerView: HorizontalPickerView) -> UIFont {
        return Theme.font(kFontVariationRegular, size: 23)
    }
}
