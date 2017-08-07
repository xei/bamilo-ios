//
//  DeliveryTimeView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 8/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class DeliveryTimeView: BaseControlView, InputTextFieldControlDelegate, DataServiceProtocol {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var regionInputView: InputTextFieldControl!
    @IBOutlet private weak var cityInputView: InputTextFieldControl!
    @IBOutlet private weak var deliveryTimeLabel: UILabel!
    
    var productSku: String!
    
    override func awakeFromNib() {
        self.titleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: UIColor.black)
        self.deliveryTimeLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: UIColor.black)
        
        self.cityInputView.delegate = self
        self.regionInputView.delegate = self
    }
    
    //TODO: this function is unnecessary but we need it for now!,
    //because in PDVVIew we have to !! change the alignment (with previous implmentations)
    func switchTheTextALignMents() {
        self.regionInputView.input.textField.textAlignment = .left
        self.cityInputView.input.textField.textAlignment = .left
        
        self.titleLabel.textAlignment = .left
        self.deliveryTimeLabel.textAlignment = .center
    }
    
    func fillTheView() {
        self.regionInputView.model = FormItemModel.init(textValue: STRING_TEHRAN, fieldName: "", andIcon: nil, placeholder: "استان", type: .options, validation: nil, selectOptions: nil)
        self.cityInputView.model = FormItemModel.init(textValue: nil, fieldName: "", andIcon: nil, placeholder: "شهر", type: .options, validation: nil, selectOptions: nil)
        self.getRegionsWithCompletion {
            self.getCitiesOfRegion(regionId: self.regionInputView.model.getValue())
        }
        self.getTimeDeliveryForCityId(cityID: nil)
    }
    
    private func updateOptionInField(inputField: InputTextFieldControl, withData: Any) {
        if let data = withData as? [AnyHashable: Any] {
            let model: FormItemModel = inputField.model
            model.selectOption = data
            if model.getValue() == nil {
                model.inputTextValue = nil;
            }
            inputField.model = model
        }
    }
    
    private func getRegionsWithCompletion(completion: @escaping ()-> Void) {
        AddressDataManager.sharedInstance.getRegions(self) { (data, error) in
            if (error == nil) {
                self.bind(data, forRequestId: 0)
                completion()
            }
        }
    }
    
    private func getCitiesOfRegion(regionId: String) {
        AddressDataManager.sharedInstance.getCities(self, regionId: regionId) { (data, error) in
            if error == nil {
                self.bind(data, forRequestId: 1)
            }
        }
    }
    
    private func getTimeDeliveryForCityId(cityID: String?) {
        ProductDataManager.sharedInstance.getDeliveryTime(self, sku: self.productSku, cityId: cityID) { (data, error) in
            if error == nil {
                self.bind(data, forRequestId: 2)
            }
        }
    }
    
    //MARK: -InputTextFieldControlDelegate
    func inputValueHasBeenChanged(_ inputTextFieldControl: Any!, byNewValue value: String!, inFieldIndex fieldIndex: UInt) {
        if let inputControl = inputTextFieldControl as? InputTextFieldControl, inputControl == self.regionInputView {
            self.getCitiesOfRegion(regionId: self.regionInputView.model.getValue())
        } else if let inputControl = inputTextFieldControl as? InputTextFieldControl, inputControl == self.cityInputView {
            self.getTimeDeliveryForCityId(cityID: inputControl.model.getValue())
        }
    }
    
    //MARK: -DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if rid == 2 {
            if let deliveryTimes = data as? DeliveryTimes, deliveryTimes.array!.count > 0, let deliveryTime = deliveryTimes.array?.first {
                self.deliveryTimeLabel.text = (deliveryTime.deliveryTimeMessage ?? "\(STRING_TEHRAN) \(deliveryTime.deliveryTimeZone1!) \n \(STRING_MINICITY) \(deliveryTime.deliveryTimeZone2!)").convertTo(language: .arabic)
            }
            return
        }
        self.updateOptionInField(inputField: rid == 0 ? self.regionInputView : self.cityInputView, withData: data)
    }
    
    
    //TODO: when we migrate all BaseControlView we need to use it as this function implementation
    override static func nibInstance() -> DeliveryTimeView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.last as! DeliveryTimeView
    }
}
