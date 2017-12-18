//
//  CatalogHeaderView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

enum CatalogListViewType: String {
    case card
    case grid
    case list
}

protocol CatalogHeaderViewDelegate:class {
    func sortTypeSelected(type: Catalog.CatalogSortType)
    func filterButtonTapped()
    func changeListViewType(type: CatalogListViewType)
}

class CatalogHeaderView: BaseControlView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet private weak var verticalSeperator: UIView!
    @IBOutlet private weak var secondVerticalSeperator: UIView!
    @IBOutlet private weak var horizontalSeperator: UIView!
    
    @IBOutlet private weak var filterTitleLabel: UILabel!
    @IBOutlet private weak var filterDescLabel: UILabel!
    @IBOutlet private weak var sortingTitleLabel: UILabel!
    @IBOutlet private weak var sortingDescLabel: UILabel!
    
    @IBOutlet private weak var filterButtonContainer: UIView!
    @IBOutlet private weak var changeListViewIconButton: IconButton!
    @IBOutlet private weak var sortIconImage: UIImageView!
    @IBOutlet private weak var filterIconImage: UIImageView!
    @IBOutlet private weak var filterButton: UIButton!
    
    private var sortingOptionInex: Int = 0
    private var pickerViewTextFiled: UITextField?
    
    private let sortOptionTranslation: [Catalog.CatalogSortType: String] = [
        .popularity: STRING_POPULARITY,
        .bestRating: STRING_BEST_RATING,
        .brand: STRING_BRAND,
        .name: STRING_NAME,
        .newest: STRING_NEW_IN,
        .priceUp: STRING_PRICE_UP,
        .priceDown: STRING_PRICE_DOWN
    ]
    private let sortingOptions: [Catalog.CatalogSortType] = [ .popularity, .bestRating, .brand, .name, .newest, .priceUp, .priceDown ]
    private let listViewTypeSequence: [CatalogListViewType] = [.grid, .list, .card]
    
    weak var delegate: CatalogHeaderViewDelegate?
    var sortType: Catalog.CatalogSortType = .popularity {
        didSet {
            self.setSortingButtonActive()
            self.sortingDescLabel.text = self.sortOptionTranslation[self.sortType]
        }
    }
    
    var listViewType: CatalogListViewType = .grid {
        didSet {
            var nextStateListType : CatalogListViewType = .grid
            if let currentIndex = self.listViewTypeSequence.index(of: self.listViewType) {
                if currentIndex + 1 > 2 {
                     nextStateListType = self.listViewTypeSequence[0]
                } else {
                    nextStateListType = self.listViewTypeSequence[currentIndex + 1]
                }
            }
            self.changeListViewIconButton.setImage(UIImage(named: "view_\(nextStateListType.rawValue)"), for: .normal)
            self.changeListViewIconButton.setImage(UIImage(named: "view_\(nextStateListType.rawValue)_active"), for: .highlighted)
        }
    }
    
    private lazy var doneButton: UIBarButtonItem = { [unowned self] in
        
        let doneBtn = UIBarButtonItem(title:"تایید", style: .plain, target: self, action: #selector(doneButtonPickerTapped(sender:)))
        doneBtn.setTitleTextAttributes([
            NSFontAttributeName: Theme.font(kFontVariationRegular, size: 13),
            NSForegroundColorAttributeName: Theme.color(kColorDarkGreen)
            ], for: .normal)
        return doneBtn
        
    }()
    
    private lazy var cancelButton: UIBarButtonItem = { [unowned self] in
        
        let cancelBtn = UIBarButtonItem(title:"لغو", style: .plain, target: self, action: #selector(cancelButtonPickerTapped(sender:)))
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
        
        let sortToolBar = UIToolbar()
        sortToolBar.barStyle = .default
        sortToolBar.isTranslucent = true
        sortToolBar.tintColor = Theme.color(kColorExtraLightGray)
        sortToolBar.backgroundColor = Theme.color(kColorExtraLightGray)
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        sortToolBar.items = [self.cancelButton, flexible, self.doneButton]
        sortToolBar.sizeToFit()
        
        return sortToolBar
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupView()
    }
    
    private func setupView() {
        self.listViewType = .grid
        self.filterIconImage.image = #imageLiteral(resourceName: "filterIcon_normal")
        self.sortIconImage.image = #imageLiteral(resourceName: "sortingIcon_normal")
        
        self.verticalSeperator.backgroundColor = Theme.color(kColorExtraExtraLightGray)
        self.horizontalSeperator.backgroundColor = Theme.color(kColorExtraExtraLightGray)
        self.secondVerticalSeperator.backgroundColor = Theme.color(kColorExtraExtraLightGray)
        self.filterButton.isEnabled = false
        
        self.filterButtonContainer.backgroundColor = UIColor.white
        self.filterTitleLabel.font = Theme.font(kFontVariationRegular, size: 11)
        self.filterTitleLabel.textColor = Theme.color(kColorDarkGray)
        self.filterDescLabel.font = Theme.font(kFontVariationRegular, size: 9)
        self.filterDescLabel.textColor = Theme.color(kColorLightGray)
        self.sortingTitleLabel.font = Theme.font(kFontVariationRegular, size: 11)
        self.sortingTitleLabel.textColor = Theme.color(kColorDarkGray)
        self.sortingDescLabel.font = Theme.font(kFontVariationRegular, size: 9)
        self.sortingDescLabel.textColor = Theme.color(kColorLightGray)
        
        self.sortingDescLabel.text = self.sortOptionTranslation[self.sortType]
    }
    
    private func setSortingButtonActive() {
        self.sortingTitleLabel.textColor = Theme.color(kColorGreen3)
        self.sortingDescLabel.textColor = Theme.color(kColorGreen5)
        self.sortIconImage.image = #imageLiteral(resourceName: "sortingIcon_highlighted")
    }
    
    func cancelButtonPickerTapped(sender: UIBarButtonItem) {
        self.pickerViewTextFiled?.resignFirstResponder()
    }
    
    func doneButtonPickerTapped(sender: UIBarButtonItem) {
        self.pickerViewTextFiled?.resignFirstResponder()
        let selectedRow = self.pickerView.selectedRow(inComponent: 0)
        self.sortingOptionInex = selectedRow
        self.sortType = self.sortingOptions[selectedRow]
        self.delegate?.sortTypeSelected(type: self.sortType)
    }
    
    func setFilterDescription(description: String) {
        self.filterDescLabel.text = description
    }
    
    func enableFilterButton(enable:Bool) {
        self.filterButton.isEnabled = enable
        self.filterButtonContainer.backgroundColor = enable ? UIColor.white : #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
        self.filterTitleLabel.textColor = enable ? Theme.color(kColorDarkGray) : Theme.color(kColorLightGray)
        self.filterDescLabel.textColor = enable ? Theme.color(kColorLightGray) : Theme.color(kColorExtraLightGray)
        self.filterIconImage.image = enable ? #imageLiteral(resourceName: "filterIcon_normal") : #imageLiteral(resourceName: "filtered_list_no_result")
    }
    
    func setFilterButtonActive () {
        self.filterTitleLabel.textColor = Theme.color(kColorGreen3)
        self.filterDescLabel.textColor = Theme.color(kColorGreen5)
        self.filterIconImage.image = #imageLiteral(resourceName: "filterIcon_highlighted")
    }
    
    @IBAction func sortButtonTapped(_ sender: Any) {
        
        if self.pickerViewTextFiled == nil {
            self.pickerViewTextFiled = UITextField(frame: CGRect.zero)
            self.addSubview(self.pickerViewTextFiled!)
            self.pickerViewTextFiled?.inputView = self.pickerView
            self.pickerViewTextFiled?.inputAccessoryView = self.toolBar
        }
        self.pickerView.selectRow(self.sortingOptionInex, inComponent: 0, animated: false)
        self.pickerViewTextFiled?.becomeFirstResponder()
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        self.delegate?.filterButtonTapped()
    }
    
    @IBAction func chageListTypeButtonTapped(_ sender: Any) {
        if let currentIndex = self.listViewTypeSequence.index(of: self.listViewType) {
            if currentIndex + 1 > 2 {
                self.listViewType = self.listViewTypeSequence[0]
            } else {
                self.listViewType = self.listViewTypeSequence[currentIndex + 1]
            }
            self.delegate?.changeListViewType(type: self.listViewType)
        }
    }
    
    //MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.sortingOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var titleView = view as? UILabel
        if titleView == nil {
            titleView = UILabel()
            titleView?.font = Theme.font(kFontVariationRegular, size: 12)
            titleView?.textAlignment = .center
            titleView?.numberOfLines = 3
        }
        titleView?.text = self.sortOptionTranslation[self.sortingOptions[row]] ?? ""
        return titleView!;
    }
    
    //TODO: when we migrate all BaseControlView we need to use it as this function implementation
    override static func nibInstance() -> CatalogHeaderView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.last as! CatalogHeaderView
    }
    
}
