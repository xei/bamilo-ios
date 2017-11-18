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

extension UIView {
    
    func bindFrameToSuperviewBounds() {
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
    
    
    func addBlurView() -> UIVisualEffectView {
        let bounds = self.bounds as CGRect!
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.frame = bounds!
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
}
