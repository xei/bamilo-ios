//
//  TourSpotLightView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

@objc protocol TourSpotLightViewDelegate {
    @objc optional func spotlightView(_ spotlightView: TourSpotLightView, willNavigateToIndex index: Int)
    @objc optional func spotlightView(_ spotlightView: TourSpotLightView, didNavigateToIndex index: Int)
    @objc optional func spotlightViewWillCleanup(_ spotlightView: TourSpotLightView, atIndex index: Int)
    @objc optional func spotlightViewDidCleanup(_ spotlightView: TourSpotLightView)
}


class TourSpotLightView: UIView {
    
    var delegate : TourSpotLightViewDelegate?
    private var skipSpotlightButton = UIButton()
    private var continueLabel = UILabel()
    // MARK: - private variables
    
    private static let kAnimationDuration = 0.3
    private static let kCutoutRadius : CGFloat = 4.0
    private static let kMaxLabelWidth: CGFloat = 280.0
    private static let kMaxLabelSpacing : CGFloat = 35.0
    private static let kMaxContinueBtnSpacing: CGFloat = 18
    private static let kEnableContinueLabel = false
    private static let kEnableSkipButton = false
    private static let kShowAllSpotlightsAtOnce = false
    private static let kTextLabelFont = UIFont.systemFont(ofSize: 20.0)
    private static let kContinueLabelHeight: CGFloat = 40
    private static let kContinueLabelWidth: CGFloat = 170
    
    private var spotlightMask = CAShapeLayer()
    private var delayTime: TimeInterval = 0.35
    
    // MARK: - public variables
    var tourName: String? //as an ID
    var continueLabelFont: UIFont = kTextLabelFont
    var continueLabelText: String = "Continue"
    var spotlightsArray: [TourSpotLight] = []
    var textLabel = UILabel()
    var spotlightMaskColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
    var animationDuration = kAnimationDuration
    var cutoutRadius : CGFloat = kCutoutRadius
    var maxLabelWidth: CGFloat = kMaxLabelWidth
    var continueWidth: CGFloat = kContinueLabelWidth
    var continueHeight: CGFloat = kContinueLabelHeight
    var labelSpacing : CGFloat = kMaxLabelSpacing
    var continueSpacing : CGFloat = kMaxContinueBtnSpacing
    var enableContinueLabel = kEnableContinueLabel
    var enableSkipButton = kEnableSkipButton
    var textLabelFont = kTextLabelFont
    var showAllSpotlightsAtOnce = kShowAllSpotlightsAtOnce
    
    var isShowed: Bool {
        return currentIndex != 0
    }
    
    var currentIndex = 0
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, spotlight: [TourSpotLight]) {
        self.init(frame: frame)
        self.spotlightsArray = spotlight
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addToSuperView(view: UIView) {
        view.addSubview(self)
        UIApplication.shared.keyWindow?.bringSubview(toFront: self)
    }
    
    private func setup() {
        setupMask()
        setupTouches()
        setupTextLabel()
        isHidden = true
    }
    
    private func setupMask() {
        spotlightMask.fillRule = kCAFillRuleEvenOdd
        spotlightMask.fillColor = spotlightMaskColor.cgColor
        layer.addSublayer(spotlightMask)
    }
    
    private func setupTouches() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userDidTap(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupTextLabel() {
        textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: maxLabelWidth, height: 0))
        textLabel.backgroundColor = .clear
        textLabel.textColor = .white
        textLabel.font = textLabelFont
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.alpha = 0
        addSubview(textLabel)
    }
    
    private func setupContinueLabel() {
        continueLabel = UILabel(frame: CGRect(x: 0, y: 0, width: continueWidth, height: continueHeight))
        continueLabel.backgroundColor = .clear
        continueLabel.textColor = .white
        continueLabel.numberOfLines = 1
        continueLabel.textAlignment = .center
        continueLabel.font = continueLabelFont
        continueLabel.alpha = 0
        continueLabel.text = continueLabelText
        continueLabel.layer.borderColor = UIColor.white.cgColor
        continueLabel.layer.borderWidth = 2
        continueLabel.layer.cornerRadius = 3
        addSubview(continueLabel)
    }
    
    private func setupSkipSpotlightButton() {
        let skipSpotlightButtonWidth = 0.3 * bounds.size.width
        let skipSpotlightButtonHeight : CGFloat = 30.0
        skipSpotlightButton = UIButton(frame: CGRect(x: 0, y: bounds.size.height - skipSpotlightButtonHeight, width: skipSpotlightButtonWidth, height: skipSpotlightButtonHeight))
        skipSpotlightButton.addTarget(self, action: #selector(skipSpotlight), for: .touchUpInside)
        skipSpotlightButton.setTitle("Skip", for: [])
        skipSpotlightButton.alpha = 0
        skipSpotlightButton.tintColor = .white
        addSubview(skipSpotlightButton)
    }
    
    // MARK: - Touches
    func userDidTap(_ recognizer: UITapGestureRecognizer) {
        goToSpotlightAtIndex(index: currentIndex + 1)
    }
    
    func start() {
        alpha = 0
        isHidden = false
        textLabel.font = textLabelFont
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = 1
        }) { (finished) in
            self.goToFirstSpotlight()
        }
    }
    
    private func goToFirstSpotlight() {
        goToSpotlightAtIndex(index: 0)
    }
    
    private func goToSpotlightAtIndex(index: Int) {
        if index >= self.spotlightsArray.count {
            cleanup()
        } else if showAllSpotlightsAtOnce {
            showSpotlightsAllAtOnce()
        } else {
            showSpotlightAtIndex(index: index)
        }
    }
    
    private func showSpotlightsAllAtOnce() {
        if let firstSpotlight = spotlightsArray.first {
            enableContinueLabel = false
            enableSkipButton = false
            setCutoutToSpotlight(spotlight: firstSpotlight)
            animateCutoutToSpotlights(spotlights: spotlightsArray)
            currentIndex = spotlightsArray.count
        }
    }
    
    private func showSpotlightAtIndex(index: Int) {
        currentIndex = index
        let currentSpotlight = spotlightsArray[index]
        delegate?.spotlightView?(self, willNavigateToIndex: index)
        showTextLabel(spotlight: currentSpotlight)
        if currentIndex == 0 {
            setCutoutToSpotlight(spotlight: currentSpotlight)
        }
        animateCutoutToSpotlight(spotlight: currentSpotlight)
        showContinueLabelIfNeeded(index: index)
        showSkipButtonIfNeeded(index: index)
    }
    
    private func showTextLabel(spotlight: TourSpotLight) {
        textLabel.alpha = 0
        calculateTextPositionAndSizeWithSpotlight(spotlight: spotlight)
        UIView.animate(withDuration: animationDuration) {
            self.textLabel.alpha = 1
        }
    }
    
    private func showContinueLabelIfNeeded(index: Int) {
        if enableContinueLabel {
            if index == 0 {
                setupContinueLabel()
                calculateContinueLabelPositionAndSizeWithSpotlight(spotlight: spotlightsArray[index])
                UIView.animate(withDuration: animationDuration, delay: delayTime, options: .curveLinear, animations: {
                    self.continueLabel.alpha = 1
                })
            } else if index >= spotlightsArray.count - 1 && continueLabel.alpha != 0 {
                continueLabel.alpha = 0
                continueLabel.removeFromSuperview()
            }
        }
    }
    
    private func showSkipButtonIfNeeded(index: Int) {
        if enableSkipButton && index == 0 {
            setupSkipSpotlightButton()
            UIView.animate(withDuration: animationDuration, delay: delayTime, options: .curveLinear, animations: {
                self.skipSpotlightButton.alpha = 1
            })
        }
    }
    
    func skipSpotlight() {
        goToSpotlightAtIndex(index: spotlightsArray.count)
    }
    
    // MARK: Helper
    private func calculateRectWithMarginForSpotlight(_ spotlight: TourSpotLight) -> CGRect {
        var rect = spotlight.rect
        
        rect.size.width += spotlight.margin.left + spotlight.margin.right
        rect.size.height += spotlight.margin.bottom + spotlight.margin.top
        
        rect.origin.x = rect.origin.x - (spotlight.margin.left + spotlight.margin.right) / 2.0
        rect.origin.y = rect.origin.y - (spotlight.margin.top + spotlight.margin.bottom) / 2.0
        
        return rect
    }
    
    private func calculateContinueLabelPositionAndSizeWithSpotlight(spotlight: TourSpotLight) {
        let rect = calculateRectWithMarginForSpotlight(spotlight)
        if textLabel.frame.origin.y < rect.origin.y {
            textLabel.frame.origin.y -= continueHeight + 2 * continueSpacing
        }
        continueLabel.frame.origin.y = textLabel.frame.origin.y + textLabel.frame.height + continueSpacing
        continueLabel.frame.origin.x = CGFloat(floor(bounds.size.width - continueWidth) / 2.0)
    }
    
    private func calculateTextPositionAndSizeWithSpotlight(spotlight: TourSpotLight) {
        textLabel.frame = CGRect(x: 0, y: 0, width: maxLabelWidth, height: 0)
        textLabel.attributedText = spotlight.attributedText
    
        textLabel.sizeToFit()
        let rect = calculateRectWithMarginForSpotlight(spotlight)
        var y = rect.origin.y + rect.size.height + labelSpacing
        let bottomY = y + textLabel.frame.size.height + labelSpacing
        if bottomY > bounds.size.height {
            y = rect.origin.y - labelSpacing - textLabel.frame.size.height
        }
        let x : CGFloat = CGFloat(floor(bounds.size.width - textLabel.frame.size.width) / 2.0)
        textLabel.frame = CGRect(origin: CGPoint(x: x, y: y), size: textLabel.frame.size)
    }
    
    // MARK: - Cutout and Animate
    private func cutoutToSpotlight(spotlight: TourSpotLight, isFirst : Bool = false) -> UIBezierPath {
        var rect = calculateRectWithMarginForSpotlight(spotlight)
        if isFirst {
            let x = floor(spotlight.rect.origin.x + (spotlight.rect.size.width / 2.0))
            let y = floor(spotlight.rect.origin.y + (spotlight.rect.size.height / 2.0))
            
            let center = CGPoint(x: x, y: y)
            rect = CGRect(origin: center, size: CGSize.zero)
        }
        let spotlightPath = UIBezierPath(rect: bounds)
        var cutoutPath = UIBezierPath()
        switch spotlight.shape {
        case .rectangle:
            cutoutPath = UIBezierPath(rect: rect)
        case .roundRectangle:
            cutoutPath = UIBezierPath(roundedRect: rect, cornerRadius: cutoutRadius)
        case .circle:
            let cirlceRadius = max(rect.height, rect.width)
            let frame = CGRect(x: rect.minX, y: rect.minY, width: cirlceRadius, height: cirlceRadius)
            cutoutPath = UIBezierPath(ovalIn: frame)
        }
        spotlightPath.append(cutoutPath)
        return spotlightPath
    }
    
    private func cutoutToSpotlightCGPath(spotlight: TourSpotLight, isFirst : Bool = false) -> CGPath {
        return cutoutToSpotlight(spotlight: spotlight, isFirst: isFirst).cgPath
    }
    
    private func setCutoutToSpotlight(spotlight: TourSpotLight) {
        spotlightMask.path = cutoutToSpotlightCGPath(spotlight: spotlight, isFirst: true)
    }
    
    private func animateCutoutToSpotlight(spotlight: TourSpotLight) {
        let path = cutoutToSpotlightCGPath(spotlight: spotlight)
        animateCutoutWithPath(path: path)
    }
    
    private func animateCutoutToSpotlights(spotlights: [TourSpotLight]) {
        let spotlightPath = UIBezierPath(rect: bounds)
        for spotlight in spotlights {
            var cutoutPath = UIBezierPath()
            switch spotlight.shape {
            case .rectangle:
                cutoutPath = UIBezierPath(rect: spotlight.rect)
            case .roundRectangle:
                cutoutPath = UIBezierPath(roundedRect: spotlight.rect, cornerRadius: cutoutRadius)
            case .circle:
                let cirlceRadius = max(spotlight.rect.height, spotlight.rect.width)
                let frame = CGRect(x: spotlight.rect.minX, y: spotlight.rect.minY, width: cirlceRadius, height: cirlceRadius)
                cutoutPath = UIBezierPath(ovalIn: frame)
            }
            spotlightPath.append(cutoutPath)
        }
        animateCutoutWithPath(path: spotlightPath.cgPath)
    }
    
    private func animateCutoutWithPath(path: CGPath) {
        let animationKeyPath = "path"
        let animation = CABasicAnimation(keyPath: animationKeyPath)
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.duration = animationDuration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.fromValue = spotlightMask.path
        animation.toValue = path
        spotlightMask.add(animation, forKey: animationKeyPath)
        spotlightMask.path = path
    }
    
    // MARK: - Cleanup
    
    private func cleanup() {
        delegate?.spotlightViewWillCleanup?(self, atIndex: currentIndex)
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = 0
        }) { (finished) in
            if finished {
                self.removeFromSuperview()
                self.currentIndex = 0
                self.textLabel.alpha = 0
                self.continueLabel.alpha = 0
                self.skipSpotlightButton.alpha = 0
                self.delegate?.spotlightViewDidCleanup?(self)
            }
        }
    }
}

extension TourSpotLightView : CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        delegate?.spotlightView?(self, didNavigateToIndex: currentIndex)
    }
}
