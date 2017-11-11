//
//  TourManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

typealias TourPresentingHandler = (_ feature: String, _ presentor: TourPresentor) -> Void

@objc protocol TourPresentor {
    func doOnBoarding(featureName: String, handler: TourPresentingHandler)
    func getScreenName() -> String!
}

@objc class TourManager: NSObject {
    
    static let shared = TourManager()
    let dict:[String:String] = ["key":"Hello"]
    
    private let defaults: UserDefaults = UserDefaults.standard
    private let featuresConfig = AppUtility.getInfoConfigs(for: "Tour") as? [String: [String]]
    
    func onBoard(presentor: TourPresentor) {
        if let featureID = self.avaiableFeature(for: presentor) {
            presentor.doOnBoarding(featureName: featureID, handler: presentorHandler(feature:presentor:))
        }
    }
    
    func presentorHandler(feature: String, presentor: TourPresentor) {
        if let screenName = presentor.getScreenName() {
            defaults.set(true, forKey: getFeatureID(screenName: screenName, featureName: feature))
            defaults.synchronize()
            self.onBoard(presentor: presentor) //for more posible features on this presentor
        }
    }
    
    func checkPresented(feature: String, presentor: TourPresentor) -> Bool {
        if let screenName = presentor.getScreenName() {
            return defaults.bool(forKey: self.getFeatureID(screenName: screenName, featureName: feature))
        }
        return false
    }
    
    private func getFeatureID(screenName: String, featureName: String) -> String {
        return "\(screenName)+\(featureName)"
    }
    
    private func avaiableFeature(for presentor: TourPresentor) -> String? {
        if let features = featuresConfig?[presentor.getScreenName()] {
            return features.filter({ !self.checkPresented(feature: $0, presentor: presentor) }).first
        }
        return nil
    }
}
