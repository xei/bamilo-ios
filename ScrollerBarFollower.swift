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
    private weak var followingScrollView: UIScrollView?
    
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
        self.followingScrollView = scrollView
    }
    
    func stopFollowing() {
        self.shouldFollower = false
        self.followingScrollView = nil
        self.delay = 0
        self.distance = 0
        self.lastContentOffset = 0
    }
    
    func pauseFollowing() {
        self.shouldFollower = false
    }
    
    func resumeFollowing() {
        self.shouldFollower = true
        self.lastContentOffset = self.followingScrollView?.contentOffset.y ?? 0
    }
    
    func resetBarFrame(animated: Bool) {
        if let barView = self.barView, let barViewInitialFrame = self.barViewInitialFrame {
            UIView.animate(withDuration: 0.15, animations: {
                barView.frame.origin.y = barViewInitialFrame.origin.y //setFrame(frame: barViewInitialFrame, animated: animated)
            })
        }
    }
    
    func hideBar(animated: Bool) {
        if let barView = self.barView, let barViewInitialFrame = self.barViewInitialFrame {
            let hiddenRect = barViewInitialFrame
            UIView.animate(withDuration: 0.15, animations: {
                barView.frame.origin.y = hiddenRect.origin.y + (self.direction == .down ? self.distance : -self.distance)
            })
        }
    }
    
    private func changeBarPositionY(difference: CGFloat) {
        self.barIsHidding = difference > 0
        guard let barViewInitialFrame = self.barViewInitialFrame else {
            return
        }
        let boundedRect = CGRect(x: barViewInitialFrame.origin.x,
                                 y: (self.direction == .top ? (barViewInitialFrame.origin.y - self.distance) : barViewInitialFrame.origin.y),
                                 width: barViewInitialFrame.width,
                                 height: barViewInitialFrame.height + self.distance)
        
        barView?.boundedVerticalMove(difference: difference, direction: self.direction, boundFrame: boundedRect)
        barView?.updateConstraints()
    }
    
    //these two methods must be called in mutaul UIScrollViewDelegate methods
    
    //return a cgfloat value between 0 and 1 to show the precentage of progress
    @discardableResult func scrollViewDidScroll(_ scrollView: UIScrollView) -> CGFloat {
        if scrollView != self.followingScrollView { return 0 }
        let scrollChanage =  scrollView.contentOffset.y - self.lastContentOffset
        self.lastContentOffset = scrollView.contentOffset.y
        
        if !self.shouldFollower || scrollView != self.followingScrollView { return 0 }
        if scrollView.contentOffset.y < self.delay {
            self.resetBarFrame(animated: false)
            return 0
        }
        
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if bottomEdge >= (scrollView.contentSize.height - 50) && scrollChanage < 0 && scrollView.contentSize.height > scrollView.frame.height {
            // we are approaching at the end of scrollview
            return 0
        }
        
        self.changeBarPositionY(difference: scrollChanage)
        
        if let barView = barView, let initialFrame = barViewInitialFrame {
            let endTargetOriginY = initialFrame.origin.y + (self.direction == .top ? -self.distance : self.distance)
            let totalDiff = abs(endTargetOriginY - initialFrame.origin.y)
            let currentDiff = abs(barView.frame.origin.y - initialFrame.origin.y)
            return currentDiff / totalDiff
        }
        return 0
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let scrollViewCanBeHide = scrollView.contentOffset.y > self.delay + self.distance
        if !decelerate || scrollView != self.followingScrollView {
            self.barIsHidding && scrollViewCanBeHide ? self.hideBar(animated: true) : self.resetBarFrame(animated: true)
        }
    }
}
