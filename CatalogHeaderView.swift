//
//  CatalogHeaderView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

enum CatalogListViewType {
    case card
    case grid
    case list
}

protocol CatalogHeaderViewDelegate {
    func sortTypeSelected(type: Catalog.CatalogSortType)
    func filterButtonTapped()
    func changeListViewType(type: CatalogListViewType)
}

class CatalogHeaderView: BaseControlView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var delegate: CatalogHeaderViewDelegate?
    var pickerViewTextFiled: UITextField?
    var sortType: Catalog.CatalogSortType = .populaity
    
    @IBOutlet weak var changeListViewIconButton: IconButton!
    @IBOutlet weak var sortIconImage: UIImageView!
    @IBOutlet weak var filterIconImage: UIImageView!
    
    lazy var doneButton: UIBarButtonItem = { [unowned self] in
        
        let doneBtn = UIBarButtonItem(title:"تایید", style: .plain, target: self, action: #selector(doneButtonPickerTapped(sender:)))
        doneBtn.setTitleTextAttributes([
            NSFontAttributeName: Theme.font(kFontVariationBold, size: 13),
            NSForegroundColorAttributeName: Theme.color(kColorBlue)
            ], for: .normal)
        return doneBtn
        
    }()
    
    lazy var cancelButton: UIBarButtonItem = { [unowned self] in
        
        let cancelBtn = UIBarButtonItem(title:"لغو", style: .plain, target: self, action: #selector(doneButtonPickerTapped(sender:)))
        cancelBtn.setTitleTextAttributes([
            NSFontAttributeName: Theme.font(kFontVariationRegular, size: 13),
            NSForegroundColorAttributeName: Theme.color(kColorDarkGray)
            ], for: .normal)
        return cancelBtn
        
        }()
    
    lazy var pickerView: UIPickerView = {
        
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.backgroundColor = UIColor.white
        picker.showsSelectionIndicator = true
        return picker
        
    }()
    
    lazy var toolBar: UIToolbar = { [unowned self] in
        
        let sortToolBar = UIToolbar()
        sortToolBar.barStyle = .default
        sortToolBar.isTranslucent = true
        sortToolBar.tintColor = Theme.color(kColorExtraLightGray)
        sortToolBar.backgroundColor = Theme.color(kColorExtraLightGray)
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        sortToolBar.items = [self.cancelButton, flexible, self.doneButton] // .setItems([flexible, self.doneButton], animated: true)
        sortToolBar.sizeToFit()
        
        return sortToolBar
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupView()
    }
    
    func setupView() {
        
    }
    
    func cancelButtonPickerTapped(sender: UIBarButtonItem) {
        self.pickerViewTextFiled?.resignFirstResponder()
    }
    
    func doneButtonPickerTapped(sender: UIBarButtonItem) {
        self.pickerViewTextFiled?.resignFirstResponder()
    }
    
    @IBAction func sortButtonTapped(_ sender: Any) {
        
        if self.pickerViewTextFiled == nil {
            self.pickerViewTextFiled = UITextField(frame: CGRect.zero)
            self.addSubview(self.pickerViewTextFiled!)
            self.pickerViewTextFiled?.inputView = self.pickerView
            self.pickerViewTextFiled?.inputAccessoryView = self.toolBar
        }
        
        self.pickerViewTextFiled?.becomeFirstResponder()
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        
    }
    
    
    //MARK - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var titleView = view as? UILabel
        if titleView == nil {
            titleView = UILabel()
            titleView?.font = Theme.font(kFontVariationRegular, size: 12)
            titleView?.numberOfLines = 3
        }
        titleView?.text = ""
        return titleView!;
    }
    
    //TODO: when we migrate all BaseControlView we need to use it as this function implementation
    override static func nibInstance() -> CatalogHeaderView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.last as! CatalogHeaderView
    }
    
}
