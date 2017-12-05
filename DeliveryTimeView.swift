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
    @IBOutlet private weak var deliveryTimeTitleLabel: UILabel!
    var productSku: String!
    
    override func awakeFromNib() {
        self.titleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: UIColor.black)
        self.deliveryTimeLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: UIColor.black)
        
        self.cityInputView.delegate = self
        self.regionInputView.delegate = self
    }
    
    //TODO: this function is unnecessary but we need it for now!,
    //because in PDVVIew we have to !! change the alignment (with previous implmentations)
    func switchTheTextAlignments() {
        self.regionInputView.input.textField.textAlignment = .left
        self.cityInputView.input.textField.textAlignment = .left
        
        self.titleLabel.textAlignment = .left
        self.deliveryTimeLabel.textAlignment = .left
    }
    
    func fillTheView() {
        self.regionInputView.model = FormItemModel.init(textValue: nil, fieldName: "", andIcon: nil, placeholder: STRING_PROVINCE, type: .options, validation: nil, selectOptions: nil)
        self.cityInputView.model = FormItemModel.init(textValue: nil, fieldName: "", andIcon: nil, placeholder: STRING_CITY, type: .options, validation: nil, selectOptions: nil)
        
        if let savedSelectedArea = UserDefaults.standard.object(forKey: "SelectedAreaByUser") as? [String: [String: String]] {
            self.regionInputView.updateModel({ (model) -> FormItemModel? in
                model?.inputTextValue = savedSelectedArea["region"]?["name"]
                return model
            })
            self.cityInputView.updateModel({ (model) -> FormItemModel? in
                model?.inputTextValue = savedSelectedArea["city"]?["name"]
                return model
            })
            self.getRegionsWithCompletion()
            self.getCitiesOfRegion(regionId: savedSelectedArea["region"]?["id"])
            self.getTimeDeliveryForCityId(cityID: savedSelectedArea["city"]?["id"])
        } else {
            self.getTimeDeliveryForCityId(cityID: nil)
        }
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
    
    private func getRegionsWithCompletion(completion: (()-> Void)? = nil) {
        AddressDataManager.sharedInstance.getRegions(self) { (data, error) in
            if (error == nil) {
                self.bind(data, forRequestId: 0)
                completion?()
            }
        }
    }
    
    private func getCitiesOfRegion(regionId: String?, completion: (() -> Void)? = nil ) {
        guard let regionId = regionId else {
            return
        }
        AddressDataManager.sharedInstance.getCities(self, regionId: regionId) { (data, error) in
            if error == nil {
                self.bind(data, forRequestId: 1)
                completion?()
            }
        }
    }
    
    private func getTimeDeliveryForCityId(cityID: String?) {
        ProductDataManager.sharedInstance.getDeliveryTime(self, sku: self.productSku, cityId: cityID) { (data, error) in
            if error == nil, let data = data {
                self.bind(data, forRequestId: 2)
            }
        }
    }
    
    //MARK: -InputTextFieldControlDelegate
    func inputValueChanged(_ inputTextFieldControl: Any!, byNewValue value: String!, inFieldIndex fieldIndex: UInt) {
        if let inputControl = inputTextFieldControl as? InputTextFieldControl, inputControl == self.regionInputView {
            self.getCitiesOfRegion(regionId: self.regionInputView.model.getValue())
        } else if let inputControl = inputTextFieldControl as? InputTextFieldControl, inputControl == self.cityInputView {
            self.getTimeDeliveryForCityId(cityID: self.cityInputView.model.getValue())
            if let regionId = self.regionInputView.model.getValue(),
               let cityId = self.cityInputView.model.getValue() {
                let selectedAreaByUser = [
                    "region" : [
                        "id": regionId,
                        "name": self.regionInputView.getStringValue()
                    ],
                    "city": [
                        "id": cityId,
                        "name": self.cityInputView.getStringValue()
                    ]
                ]
                UserDefaults.standard.set(selectedAreaByUser, forKey: "SelectedAreaByUser")
            }
        }
    }
    
    //MARK: -DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if rid == 2 {
            if let deliveryTimes = data as? DeliveryTimes, let deliveries = deliveryTimes.array, deliveries.count > 0, let deliveryTime = deliveryTimes.array?.first {
                if let deliveryTimeZone1 = deliveryTime.deliveryTimeZone1, let deliveryTimeZone2 = deliveryTime.deliveryTimeZone2 {
                    self.deliveryTimeLabel.text = (deliveryTime.deliveryTimeMessage ?? "\(STRING_TEHRAN) \(deliveryTimeZone1)\n\(STRING_MINICITY) \(deliveryTimeZone2)").convertTo(language: .arabic)
                }
                self.deliveryTimeTitleLabel.text = "\(deliveryTime.deliveryTimeMessage != nil ?  STRING_DELIVERY_TIME : STRING_ESTIMATED_TIME):"
                
                if let cityId = deliveryTimes.cityId, let regionId = deliveryTimes.regionId {
                    self.getRegionsWithCompletion {
                        self.getCitiesOfRegion(regionId: regionId, completion: { 
                            self.regionInputView.updateModel({ (model) -> FormItemModel? in
                                model?.setValue(regionId)
                                return model
                            })
                            self.cityInputView.updateModel({ (model) -> FormItemModel? in
                                model?.setValue(cityId)
                                return model
                            });
                        })
                    }
                } else {
                    self.getRegionsWithCompletion()
                }
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
