//
//  NPSQuestionView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/10/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher
import AudioToolbox

class NPSQuestionView: BaseSurveyQuestionControlView, HorizontalPickerViewDelegate, HorizontalPickerViewDataSource {

    @IBOutlet weak private var hintUILabel: UILabel!
    @IBOutlet weak private var questionTitle: UILabel!
    @IBOutlet weak private var optionImageView: UIImageView!
    @IBOutlet weak private var selectionIndicatorUIImage: UIImageView!
    @IBOutlet weak private var horizontalPickerView: HorizontalPickerView!
    private var isPreselecting: Bool = false
    
    override func update(model: SurveyQuestion) {
        super.update(model: model)
        self.questionTitle.text = self.questionModel?.title
        self.horizontalPickerView.reloadAll()
        self.horizontalPickerView.tintColor = Theme.color(kColorOrange)
        
        //Do after horizontalPicker updated
        if let options = self.questionModel?.options {
//            //get seleted Index or get third quarter index
            var selectedIndex = options.index(where: { $0.isSelected ?? false })
            if selectedIndex == nil {
                self.isPreselecting = true
                selectedIndex = Int((options.count - 1 + (options.count / 2)) / 2)
            }
            ThreadManager.execute {
                self.horizontalPickerView.selectRow(rowIndex: 5, animated: false)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.hintUILabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 10), color: UIColor.lightGray)
        self.questionTitle.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        self.horizontalPickerView.delegate = self
        self.horizontalPickerView.dataSource = self
        self.horizontalPickerView.bounces = false
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
        if isPreselecting {
            self.isPreselecting = false
            self.setUntouchedState(for: row)
            return
        }
        self.hintUILabel.text = nil
        self.selectionIndicatorUIImage.image = #imageLiteral(resourceName: "outlineCircle")
        self.questionModel?.haveAnswer = true
        if let options = self.questionModel?.options, row < options.count {
            for i in 0..<options.count {
                options[i].isSelected = false
            }
            options[row].isSelected = true
            self.optionImageView.kf.setImage(with: options[row].image, options: [.transition(.fade(0.20))])
        }
        AudioServicesPlaySystemSound(1519)
    }
    
    private func setUntouchedState(for index: Int) {
        if let options = self.questionModel?.options, index < options.count {
            self.optionImageView.isHidden = true
            self.optionImageView.kf.setImage(with: options[index].image, options: [.transition(.fade(0.20))]) { (image, error, cach, url) in
                DispatchQueue.global(qos: .background).async {
                    let blackWhiteImage = image?.noir
                    let selectionIndicatorBlackWhite =  #imageLiteral(resourceName: "outlineCircle").noir
                    DispatchQueue.main.async {
                        self.optionImageView.image = blackWhiteImage
                        self.selectionIndicatorUIImage.image = selectionIndicatorBlackWhite
                        self.optionImageView.isHidden = false
                    }
                }
            }
        }
        self.hintUILabel.text = STRING_PLEASE_SELECT_YOUR_CHOICE
    }
    
    func textColorForHorizontalPickerView(pickerView: HorizontalPickerView) -> UIColor {
        return UIColor.lightGray
    }
    
    func textFontForHorizontalPickerView(pickerView: HorizontalPickerView) -> UIFont {
        return Theme.font(kFontVariationRegular, size: 23)
    }
}
