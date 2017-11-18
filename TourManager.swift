//
//  TourManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

typealias TourPresentingHandler = (_ feature: String, _ presenter: TourPresenter) -> Void

@objc protocol TourPresenter {
    func doOnBoarding(featureName: String, handler: @escaping TourPresentingHandler)
    func getScreenName() -> String!
}

@objc class TourManager: NSObject {
    
    static let shared = TourManager()

    private let defaults: UserDefaults = UserDefaults.standard
    private let featuresConfig = AppUtility.getInfoConfigs(for: "Tour") as? [String: [String]]
    
    func onBoard(presenter: TourPresenter) {
        if let featureID = self.avaiableFeature(for: presenter) {
            presenter.doOnBoarding(featureName: featureID, handler: presenterHandler(feature:presenter:))
        }
    }
    
    func presenterHandler(feature: String, presenter: TourPresenter) {
        if let screenName = presenter.getScreenName() {
            defaults.set(true, forKey: getFeatureID(screenName: screenName, featureName: feature))
            defaults.synchronize()
            self.onBoard(presenter: presenter) //for more possible features on this presenter
        }
    }
    
    func checkPresented(feature: String, presenter: TourPresenter) -> Bool {
        if let screenName = presenter.getScreenName() {
            return defaults.bool(forKey: self.getFeatureID(screenName: screenName, featureName: feature))
        }
        return false
    }
    
    private func getFeatureID(screenName: String, featureName: String) -> String {
        return "\(screenName)+\(featureName)"
    }
    
    private func avaiableFeature(for presenter: TourPresenter) -> String? {
        if let features = featuresConfig?[presenter.getScreenName()] {
            return features.filter({ !self.checkPresented(feature: $0, presenter: presenter) }).first
        }
        return nil
    }
}
