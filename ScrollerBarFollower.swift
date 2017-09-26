//
//  ScrollerBarFollower.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit


@objc class ScrollerBarFollower:NSObject {
    
    private var barView: UIView?
    private var delay: CGFloat!
    private var direction: VerticalMoveDirection = .top
    private var distance: CGFloat!
    private var barViewInitialFrame: CGRect?
    private var barIsHidding = false
    private var lastContentOffset: CGFloat = 0
    private var shouldFollower = false
    
    override init() {
        super.init()
    }
    
    init(barView: UIView, moveDirection: VerticalMoveDirection) {
        super.init()
        self.set(barView: barView, moveDirection: moveDirection.rawValue)
    }
    
    //This function is unnecessary we've just used it in objective c codes!
    func set(barView: UIView, moveDirection: String) {
        self.barView = barView
        self.barViewInitialFrame = barView.frame
        self.direction = VerticalMoveDirection(rawValue: moveDirection) ?? .top
    }
      
    func followScrollView(scrollView: UIScrollView, delay: CGFloat, permittedMoveDistance: CGFloat) {
        self.delay = delay
        self.distance = permittedMoveDistance
        self.lastContentOffset = scrollView.contentOffset.y
        self.shouldFollower = true
    }
    
    func stopFollowing() {
        self.shouldFollower = false
    }
    
    func resetBarFrame(animated: Bool) {
        if let barView = self.barView, let barViewInitialFrame = self.barViewInitialFrame {
            barView.setFrame(frame: barViewInitialFrame, animated: animated)
        }
    }
    
    func hideBar(animated: Bool) {
        if let barView = self.barView, let barViewInitialFrame = self.barViewInitialFrame {
            var hiddenRect = barViewInitialFrame
            hiddenRect.origin.y = hiddenRect.origin.y + (self.direction == .down ? self.distance : -self.distance)
            barView.setFrame(frame: hiddenRect, animated: animated)
        }
    }
    
    func changeBarPositionY(difference: CGFloat) {
        self.barIsHidding = difference > 0
        guard let barViewInitialFrame = self.barViewInitialFrame else {
            return
        }
        let boundedRect = CGRect(x: barViewInitialFrame.origin.x,
                                 y: (self.direction == .top ? (barViewInitialFrame.origin.y - self.distance) : barViewInitialFrame.origin.y),
                                 width: barViewInitialFrame.width,
                                 height: barViewInitialFrame.height + self.distance)
        
        barView?.boundedVerticalMove(difference: difference, direction: self.direction, boundFrame: boundedRect)
    }
    
    //these two methods must be called in mutaul UIScrollViewDelegate methods 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.shouldFollower { return }
        if scrollView.contentOffset.y < self.delay {
            self.resetBarFrame(animated: false)
            self.lastContentOffset = scrollView.contentOffset.y
            return
        }

        let scrollChanage =  scrollView.contentOffset.y - self.lastContentOffset
        self.changeBarPositionY(difference: scrollChanage)
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.barIsHidding ? self.hideBar(animated: false) : self.resetBarFrame(animated: true)
            
        }
    }
}
