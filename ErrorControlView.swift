//
//  ErrorControlView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 12/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

typealias ErrorControlCallBack = (@escaping ErrorControlHandleRetry) -> Void
typealias ErrorControlHandleRetry = (Bool) -> Void

@objcMembers class ErrorControlView: BaseControlView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var callBack: ErrorControlCallBack?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.messageLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 16), color: Theme.color(kColorGray1))
        self.retryButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 14), color: Theme.color(kColorGray1))
        self.retryButton.setTitle(STRING_TRY_AGAIN, for: .normal)
        self.settingButton.setTitle(STRING_INTERNET_SETTING, for: .normal)
        self.timerLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray3))
        self.settingButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 14), color: Theme.color(kColorDarkGreen3))
        self.retryButton.setTitleColor(Theme.color(kColorGray5), for: .disabled)
        self.activityIndicator.stopAnimating()
        
        
        self.retryButton.layer.borderColor = Theme.color(kColorGray7).cgColor
        self.retryButton.layer.borderWidth = 1
        self.retryButton.layer.cornerRadius = 3
    }
    
    func update(with errorCode: Int, callBack: ErrorControlCallBack? = nil) {
        switch errorCode {
        case NSURLErrorNotConnectedToInternet,
             NSURLErrorNetworkConnectionLost:
            //Internet or connection error
            self.messageLabel.text = STRING_NO_NETWORK
            self.imageView.image = #imageLiteral(resourceName: "img_nonetwork")
            if #available(iOS 10.0, *) {
                self.settingButton.isHidden = false
            } else {
                self.settingButton.isHidden = true
            }
            self.retryButton.isHidden = callBack == nil
            self.timerLabel.isHidden = true
        default:
            
            self.messageLabel.text = STRING_SERVER_CONNECTION_ERROR_MESSAGE
            self.imageView.image = #imageLiteral(resourceName: "server_connection_error")
            self.timerLabel.text = STRING_PLEASE_WAIT
            self.settingButton.isHidden = true
            self.retryButton.isHidden = true
            self.timerLabel.isHidden = false
            if callBack != nil {
                //After 5 seconds
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                    //if this view is still avaiable
                    self.retryButton?.fadeIn(duration: 0.15)
                }
            }
        }
        
        
        self.callBack = callBack
    }
    
    @IBAction func retryButtonTapped(_ sender: Any) {
        self.callBack? { success in
            self.handleRetryResponse(success: success)
        }
        self.retryButton.isHidden = true
        self.activityIndicator.startAnimating()
    }
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        guard let settingsUrl = URL(string: "App-Prefs:root=WIFI") else {
            self.retryButton.isHidden = true
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl)
            } else {
                self.retryButton.isHidden = true
            }
        } else {
            self.retryButton.isHidden = true
        }
    }
    
    
    private func handleRetryResponse(success: Bool) {
        self.removeFromSuperview()
        if success {
            return
        }
        self.activityIndicator.stopAnimating()
        self.retryButton.isHidden = false
    }
    
    
    //TODO: when we migrate all BaseControlView we need to use it as this function implementation
    override class func nibInstance() -> ErrorControlView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.last as! ErrorControlView
    }
}
