//
//  GoogleAnalyticsTracker.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

class GoogleAnalyticsTracker: BaseTracker, EventTrackerProtocol {

    var campaginDataString: String?
    
    //TODO: Must be changed when we migrate all Trackers
    private static var sharedInstance: GoogleAnalyticsTracker? // = GoogleAnalyticsTracker()
    override class func shared() -> GoogleAnalyticsTracker {
        if sharedInstance == nil {
            sharedInstance = GoogleAnalyticsTracker()
            sharedInstance?.setConfig()
        }
        return sharedInstance!
    }
    
    func setConfig() {
        // Automatically send uncaught exceptions to Google Analytics.
        GAI.sharedInstance().trackUncaughtExceptions = true
        
        // Dispatch tracking information every 5 seconds (default: 120)
        GAI.sharedInstance().dispatchInterval = 5
        GAI.sharedInstance().logger.logLevel = .none
        
        let GAID = (Bundle.main.object(forInfoDictionaryKey: "Configs") as? [String:Any])?["GoogleAnalyticsID"] as? String
        GAI.sharedInstance().tracker(withTrackingId: GAID)
        
        GAI.sharedInstance().defaultTracker.set(kGAIAppVersion, value: AppManager.sharedInstance().getAppFullFormattedVersion() ?? "")
        
        GAI.sharedInstance().defaultTracker.allowIDFACollection = true
    }
    
    func travckScreenName(screenName:String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: screenName)
        var builder = GAIDictionaryBuilder.createScreenView()
        if let campaignString = self.campaginDataString {
            builder = builder?.setCampaignParametersFromUrl(campaignString)
        }
        tracker?.send(builder!.build() as! [AnyHashable : Any])
    }
    
    func trackCampaignData(campaignDictionary: [String: String]) {
        if campaignDictionary.count > 0 {
            var params = [String]()
            
            if let utmCampaign = campaignDictionary[kUTMCampaign] {
                params += ["\(kUTMCampaign)=\(utmCampaign)"]
            }
            if let utmContent = campaignDictionary[kUTMContent] {
                params += ["\(kUTMContent)=\(utmContent)"]
            }
            if let utmTerm = campaignDictionary[kUTMTerm] {
                params += ["\(kUTMTerm)=\(utmTerm)"]
            }
            
            
            if let utmSource = campaignDictionary[kUTMSource], utmSource.characters.count > 0 {
                if let _ = campaignDictionary[kUTMCampaign] {
                    params += ["\(kUTMSource)=push"]
                } else {
                    params += ["\(kUTMSource)=\(utmSource)"]
                }
            }
            
            if let utmMedium = campaignDictionary[kUTMMedium], utmMedium.characters.count > 0 {
                if let _ = campaignDictionary[kUTMCampaign] {
                    params += ["\(kUTMMedium)=referrer"]
                } else {
                    params += ["\(kUTMMedium)=\(utmMedium)"]
                }
            }
            
            self.campaginDataString = params.joined(separator:"&")
        }
    }
    
    
    //MARK: -EventTrackerProtocol
    func search(attributes: EventAttributeType) {
        let params = GAIDictionaryBuilder.createEvent(
            withCategory: "Catalog",
            action: "Search",
            label: (attributes[kEventSearchTarget] as? RITarget)?.node,
            value: nil
        )
        self.sendParamsToGA(params: params)
    }
    
    func searchbarSearched(attributes: EventAttributeType) {
        if let screenName = attributes[kEventScreenName] as? String, let searchString = attributes[kEventKeywords] as? String {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: screenName,
                action: "Search",
                label: searchString,
                value: nil
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    func searchFiltered(attributes: EventAttributeType) {
        if let filterQuery = attributes[kEventFilterQuery] as? String {
            let arrayOfFilterKeysAndValues = filterQuery.components(separatedBy: "/")
            let filterKeys = arrayOfFilterKeysAndValues.enumerated().flatMap { $0 % 2 == 0 ? $1 : nil}.joined(separator: ", ")
            //let filterValues = arrayOfFilterKeysAndValues.enumerated().flatMap { $0 % 2 != 0 ? $1 : nil}.joined(separator: ", ")
            
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: "Catalog",
                action: "Filters",
                label:filterKeys,
                value: nil
            )
            
            self.sendParamsToGA(params: params)
        }
    }
    
    func recommendationTapped(attributes: EventAttributeType) {
        if let screenName = attributes[kEventScreenName] as? String, let logic = attributes[kEventRecommendationLogic] as? String {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: "Emarsys",
                action: "Click",
                label: "\(screenName)-\(logic)",
                value: nil
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    
    //MARK: - Helper functions
    private func sendParamsToGA(params: GAIDictionaryBuilder?) {
        guard let params = params else { return }
        if let campaignStrig = self.campaginDataString,  campaignStrig.characters.count > 0 {
            let _ = params.setCampaignParametersFromUrl(campaignStrig)
        }
        GAI.sharedInstance().defaultTracker.send(params.build() as! [AnyHashable : Any])
    }
}
