//
//  YPMagnifyingView.swift
//  YPMagnifyingGlass
//
//  Created by Geert-Jan Nilsen on 02/06/15.
//  Copyright (c) 2015 Yuppielabel.com All rights reserved.
//

import UIKit

public class YPMagnifyingView: UIView {
    
    public var YPMagnifyingViewDefaultShowDelay: TimeInterval = 0.2;
    
    private var magnifyingGlassShowDelay: TimeInterval
    
    private var touchTimer: Timer!
    
    public var magnifyingGlass: YPMagnifyingGlass = YPMagnifyingGlass()
    
    override public init(frame: CGRect) {
        self.magnifyingGlassShowDelay = YPMagnifyingViewDefaultShowDelay
        super.init(frame: frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        self.magnifyingGlassShowDelay = YPMagnifyingViewDefaultShowDelay
        super.init(coder: aDecoder)!
    }
    
    // MARK: - Private Functions
    
    private func addMagnifyingGlassAtPoint(point: CGPoint) {
        self.magnifyingGlass.viewToMagnify = self as UIView
        self.magnifyingGlass.touchPoint = point
        
        let selfView: UIView = self as UIView
        
        selfView.addSubview(self.magnifyingGlass)
        
        self.magnifyingGlass.setNeedsDisplay()
    }
    
    private func removeMagnifyingGlass() {
        self.magnifyingGlass.removeFromSuperview()
    }
    
    private func updateMagnifyingGlassAtPoint(point: CGPoint) {
        self.magnifyingGlass.touchPoint = point
        self.magnifyingGlass.setNeedsDisplay()
    }
    
    public func addMagnifyingGlassTimer(timer: Timer) {
        let value: AnyObject? = timer.userInfo as AnyObject?
        if let point = value?.cgPointValue {
            self.addMagnifyingGlassAtPoint(point: point)
        }
    }
}
