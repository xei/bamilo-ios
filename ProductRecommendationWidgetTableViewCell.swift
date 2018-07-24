//
//  ProductRecommendationWidgetTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/21/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductRecommendationWidgetTableViewCell: BaseProductTableViewCell {

    @IBOutlet weak private var widgetView: EmarsysRecommendationGridWidget!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerBoxView?.backgroundColor = .clear
    }
    
    override func update(withModel model: Any!) {
        
        widgetView.backgroundColor = .clear
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        if let recommendItems = model as? [RecommendItem] {
            widgetView.widgetView.update(withModel: recommendItems)
        }
    }
    
    
    func setDelegate(delegate: FeatureBoxCollectionViewWidgetViewDelegate) {
        widgetView.setDelegate(delegate)
    }
}
