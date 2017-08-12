//
//  Ext+UIView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 8/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

enum VerticalMoveDirection {
    case top
    case down
}

extension UIView {
    func boundedStickyVerticalMove(difference: CGFloat, direction: VerticalMoveDirection, initialFrame: CGRect) {
        let positionY = self.frame.origin.y
        let goalPositionY = positionY +  (direction == .down ? difference: -difference)
        if direction == .down && goalPositionY < initialFrame.origin.y || direction == .top && goalPositionY > initialFrame.origin.y {
            self.frame = initialFrame
        } else if direction == .down && goalPositionY > initialFrame.origin.y + initialFrame.size.height {
            self.frame.origin.y = initialFrame.origin.y + initialFrame.size.height
        } else if direction == .top && goalPositionY < initialFrame.origin.y - initialFrame.size.height {
            self.frame.origin.y = initialFrame.origin.y - initialFrame.size.height
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
}
