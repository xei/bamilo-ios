//
//  ScrollerBarFollower.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit


class ScrollerBarFollower:NSObject {
    
    private var barView: UIView?
    private var delay: CGFloat!
    private var direction: VerticalMoveDirection = .top
    private var distance: CGFloat!
    private var barViewInitialFrame: CGRect?
    private var barIsHidding = false
    private var lastContentOffset: CGFloat = 0
    private var shouldFollower = true
    
    init(withBarView barView: UIView, moveDirection: VerticalMoveDirection) {
        self.barView = barView
        self.barViewInitialFrame = barView.frame
        self.direction = moveDirection
    }
      
    func followScrollView(scrollView: UIScrollView, delay: CGFloat? = 0, permittedMoveDistance: CGFloat) {
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
        if (scrollView.contentOffset.y < self.delay) {
            self.resetBarFrame(animated: false)
            self.lastContentOffset = scrollView.contentOffset.y
            return
        }

        let scrollChanage =  scrollView.contentOffset.y - self.lastContentOffset
        self.changeBarPositionY(difference: scrollChanage)
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate || !self.shouldFollower {
            self.barIsHidding ? self.hideBar(animated: true) : self.resetBarFrame(animated: true)
        }
    }
}
