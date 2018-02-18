//
//  OrderCancellationTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/9/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

class OrderCancellationTableViewCell: AccordionTableViewCell, StepperViewControlDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak private var notCacelableReasonLabel: UILabel!
    @IBOutlet weak private var disabledCoverView: UIView!
    @IBOutlet weak private var cancellingTitleLabel: UILabel!
    @IBOutlet weak private var productImage: UIImageView!
    @IBOutlet weak private var quantityStepper: StepperViewControl!
    @IBOutlet weak private var productTitleLabel: UILabel!
    @IBOutlet weak private var productAttributeLabel: UILabel!
    @IBOutlet weak private var quantityTitleLabel: UILabel!
    @IBOutlet weak private var cancellationReasonFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancellationReasonFieldView: UIView!
    
    private var pickerViewTextFiled: UITextField?
    private var cancellingItem : CancellingOrderProduct?
    private var cancellingReasons : [OrderCancellationReason]?
    
    private lazy var doneButton: UIBarButtonItem = { [unowned self] in
        let doneBtn = UIBarButtonItem(title: STRING_OK_LABEL, style: .plain, target: self, action: #selector(doneButtonPickerTapped(sender:)))
        doneBtn.setTitleTextAttributes([
            NSFontAttributeName: Theme.font(kFontVariationRegular, size: 13),
            NSForegroundColorAttributeName: Theme.color(kColorDarkGreen)
            ], for: .normal)
        return doneBtn
    }()
    
    private lazy var cancelButton: UIBarButtonItem = { [unowned self] in
        let cancelBtn = UIBarButtonItem(title: STRING_CANCEL, style: .plain, target: self, action: #selector(cancelButtonPickerTapped(sender:)))
        cancelBtn.setTitleTextAttributes([
            NSFontAttributeName: Theme.font(kFontVariationRegular, size: 13),
            NSForegroundColorAttributeName: Theme.color(kColorDarkGreen)
            ], for: .normal)
        return cancelBtn
    }()
    
    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.backgroundColor = UIColor.white
        picker.showsSelectionIndicator = true
        return picker
    }()
    
    private lazy var toolBar: UIToolbar = { [unowned self] in
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = Theme.color(kColorExtraLightGray)
        toolBar.backgroundColor = Theme.color(kColorExtraLightGray)
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [self.cancelButton, flexible, self.doneButton]
        toolBar.sizeToFit()
        return toolBar
    }()
    
    func cancelButtonPickerTapped(sender: UIBarButtonItem) {
        self.pickerViewTextFiled?.resignFirstResponder()
    }
    
    func doneButtonPickerTapped(sender: UIBarButtonItem) {
        self.pickerViewTextFiled?.resignFirstResponder()
        let selectedIndex = self.pickerView.selectedRow(inComponent: 0)
        self.selectSelectionIndex(index: selectedIndex)
    }
    
    private func selectSelectionIndex(index: Int) {
        self.cancellingReasons?.forEach { $0.isSelected = false }
        self.cancellingItem?.reasonId = self.cancellingReasons?[index].id
        self.cancellingReasons?[index].isSelected = true
        self.updateReasonsUI()
    }
    
    private func updateReasonsUI() {
        if let reasons = self.cancellingReasons {
            let index = reasons.index(where: { $0.isSelected })
            if reasons.count > index ?? 0 {
                self.cancellingTitleLabel.text = reasons[index ?? 0].title
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.quantityStepper.delegate = self
        self.setupStyles()
        self.disabledCoverView.backgroundColor = .white
        self.disabledCoverView.alpha = 0.5
    }
    
    func setupStyles() {
        self.productTitleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.productAttributeLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.quantityTitleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 11), color: Theme.color(kColorSecondaryGray1))
        self.cancellationReasonFieldView.applyBorder(width: 1, color: Theme.color(kColorGray9))
        self.cancellationReasonFieldView.layer.cornerRadius = 3
        self.cancellingTitleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        self.notCacelableReasonLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGreen3))
    }
    
    //MARK : - StepperViewControlDelegate
    func valueHasBeenChanged(_ stepperViewControl: Any!, withNewValue value: Int32) {
        self.cancellingItem?.cancellingQuantity = Int(value)
    }
    func wants(toBeMoreThanMax stepperViewControl: Any!) {}
    func wants(toBeLessThanMin stepperViewControl: Any!) {}
    
    
    func update(cancellingItem: CancellingOrderProduct, cancellingReasons: [OrderCancellationReason]) {
        self.productTitleLabel.text = cancellingItem.name
        if let color = cancellingItem.color {
            self.productAttributeLabel.text = "\(STRING_COLOR): \(color)"
        }
        self.productImage.kf.setImage(with: cancellingItem.imageUrl, placeholder: UIImage(named: "placeholder_list"), options: [.transition(.fade(0.20))])
        
        self.quantityStepper.isHidden = false
        self.quantityStepper.quantity = Int32(cancellingItem.cancellingQuantity)
        self.quantityStepper.maxQuantity = Int32(cancellingItem.quantity ?? 0)
        self.quantityStepper.minQuantity = min(self.quantityStepper.maxQuantity, 1)
        
        //if we have only one quantity of this product
        if cancellingItem.quantity == 1  {
            self.quantityStepper.isHidden = true
        }
        
        self.cancellationReasonFieldView.isHidden = !cancellingItem.isCancelable
        self.notCacelableReasonLabel.isHidden = cancellingItem.isCancelable
        self.notCacelableReasonLabel.text = cancellingItem.notCancelableReason ?? NOT_CANCELABLE_DEFAULT_REASON

        self.isUserInteractionEnabled = cancellingItem.isCancelable
        self.disabledCoverView.isHidden = cancellingItem.isCancelable

        self.cancellingItem = cancellingItem
        self.cancellingReasons = cancellingReasons

        self.cancellingItem?.reasonId = self.cancellingItem?.reasonId ?? self.cancellingReasons?.first?.id
        self.updateReasonsUI()
    }
    
    override func setExpanded(_ expanded: Bool, animated: Bool) {
        super.setExpanded(expanded, animated: animated)
        self.setPropoerConstraints(expanded: expanded)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    @IBAction func cancellingReasonButtonTapped(_ sender: Any) {
        if self.pickerViewTextFiled == nil {
            self.pickerViewTextFiled = UITextField(frame: CGRect.zero)
            self.addSubview(self.pickerViewTextFiled!)
            self.pickerViewTextFiled?.inputView = self.pickerView
            self.pickerViewTextFiled?.inputAccessoryView = self.toolBar
        }
        self.pickerViewTextFiled?.becomeFirstResponder()
    }
    
    //MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.cancellingReasons?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var titleView = view as? UILabel
        if titleView == nil {
            titleView = UILabel()
            titleView?.font = Theme.font(kFontVariationRegular, size: 12)
            titleView?.textAlignment = .center
            titleView?.numberOfLines = 3
        }
        titleView?.text = self.cancellingReasons?[row].title ?? ""
        return titleView!;
    }
    
    private func setPropoerConstraints(expanded: Bool) {
        //to set the height of cell via
        self.cancellationReasonFieldHeightConstraint.constant = expanded ? 42 : 0
        self.layoutIfNeeded()
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
