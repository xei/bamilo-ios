//
//  Ext+UIView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 8/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

enum VerticalMoveDirection: String {
    case top = "TOP"
    case down = "DOWN"
}

typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)
enum GradientOrientation {
    case topRightBottomLeft
    case topLeftBottomRight
    case horizontal
    case vertical
    
    var startPoint : CGPoint {
        return points.startPoint
    }
    
    var endPoint : CGPoint {
        return points.endPoint
    }
    
    var points : GradientPoints {
        get {
            switch(self) {
            case .topRightBottomLeft:
                return (CGPoint(x: 0.0,y: 1.0), CGPoint(x: 1.0,y: 0.0))
            case .topLeftBottomRight:
                return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 1,y: 1))
            case .horizontal:
                return (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5))
            case .vertical:
                return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 0.0,y: 1.0))
            }
        }
    }
}

extension UIView {

    func hide() {
        self.isHidden = true
        self.alpha = 0
    }

    func fadeIn(duration: TimeInterval) {
        self.isHidden = false
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        })
    }

    func applyShadow(position:CGSize, color: UIColor, opacity: Float? = 0.5, radius: CGFloat? = 1) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity ?? 1
        self.layer.shadowOffset = position
        self.layer.shadowRadius = radius ?? 1
    }

    func applyBorder(width: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }

    @objc func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }

    func boundedVerticalMove(difference: CGFloat, direction: VerticalMoveDirection, boundFrame: CGRect) {
        let positionY = self.frame.origin.y
        let goalPositionY = positionY + (direction == .down ? difference: -difference)
        if goalPositionY < boundFrame.origin.y {
            self.frame.origin.y = boundFrame.origin.y
        } else if goalPositionY + self.frame.height > boundFrame.origin.y + boundFrame.height {
            self.frame.origin.y = boundFrame.origin.y + boundFrame.height - self.frame.height
        } else {
            self.frame = self.frame.offsetBy(dx: 0, dy: direction == .down ? difference : -difference)
        }
    }

    func setFrame(frame: CGRect, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.15, animations: {
                self.frame = frame
                self.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.frame = frame
        }
    }


    @discardableResult func addBlurView(style: UIBlurEffectStyle = .light) -> UIVisualEffectView {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        visualEffectView.frame = self.bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(visualEffectView)
        return visualEffectView
    }

    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    /**
       Create gradient for view
     - parameter locations: Array of The values between 0 and 1, which gradient stops are specified as values
     */
    func applyGradient(colours: [UIColor], locations: [Double]? = nil, orientation: GradientOrientation = .horizontal) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.isOpaque = true
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        gradient.locations = locations?.map { NSNumber(value: $0) }
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    @objc func addAnchorMatchedSubView(view: UIView) {

        view.frame = self.bounds;
        self.addSubview(view)

        self.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0))
    }
}
