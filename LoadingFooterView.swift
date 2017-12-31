//
//  LoadingFooterView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/4/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class LoadingFooterView: BaseControlView {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
