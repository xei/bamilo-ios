//
//  ProductMoreInfoViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/26/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit


enum SelectedViewType {
    case description
    case specicifation
}

class ProductMoreInfoViewController: BaseViewController {
    
    var product: Product?
    var selectedViewType: SelectedViewType = .description
    
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    @IBOutlet private weak var seperatorView: UIView!
    @IBOutlet private weak var descriptionContainerView: UIView!
    @IBOutlet private weak var specificationsContainerView: UIView!
    @IBOutlet private weak var descriptionContainerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var specificationContainerBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        
        self.segmentControl.selectedSegmentIndex = selectedViewType == .description ? 1 : 0
        indexChanged(segmentControl)
        
        if let tabbarHeight = self.tabBarController?.tabBar.frame.height {
            [descriptionContainerViewBottomConstraint, specificationContainerBottomConstraint].forEach { $0.constant = tabbarHeight }
        }
    }
    
    func applyStyle() {
        view.backgroundColor = .white
        segmentControl.setTitleTextAttributes([NSAttributedStringKey.font: Theme.font(kFontVariationRegular, size: 12)], for: .normal)
        segmentControl.tintColor = Theme.color(kColorOrange1)
        seperatorView.backgroundColor = Theme.color(kColorGray10)
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.descriptionContainerView.hide()
            self.specificationsContainerView.fadeIn(duration: 0.15)
        case 1:
            self.specificationsContainerView.hide()
            self.descriptionContainerView.fadeIn(duration: 0.15)
        default: break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "embedProductDescriptionsViewController", let viewCtrl = segue.destination as? ProductDescriptionsViewController, let description = self.product?.productDescription {
            viewCtrl.productDescription = description
        } else if segueName == "embedProductSpecificsTableViewController", let viewCtrl = segue.destination as? ProductSpecificsTableViewController , let specifications = product?.specifications {
            viewCtrl.model = specifications
        }
    }
}
