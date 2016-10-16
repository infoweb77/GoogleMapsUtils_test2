//
//  GDefaultClusterMarkerIconView.swift
//  GoogleMapsUtils_test
//
//  Created by alex on 04/10/16.
//  Copyright © 2016 alex. All rights reserved.
//

import UIKit

final class GDefaultClusterMarkerIconView: UIView {
    
    static let buckets = [ 10, 25, 50, 100, 250, 500, 1000 ]
    static let bucketColors: [UInt64] = [ 0x006699, 0x009966, 0x669900, 0xff8800, 0xffcc00, 0xcc0000, 0x9933cc ]
    
    static func bucketIndexForCount(count: Int) -> Int {
        var index = 0
        let buckets = GDefaultClusterMarkerIconView.buckets
        while index + 1 < buckets.count && buckets[index + 1] <= count {
            ++index
        }
        return index
    }
    
    static func textForCount(count: Int) -> String {
        if count < GDefaultClusterMarkerIconView.buckets[0] {
            return "\(count)"
        }
        else {
            let index = GDefaultClusterMarkerIconView.bucketIndexForCount(count)
            return "\(GDefaultClusterMarkerIconView.buckets[index])+"
        }
    }
    
    private var _count: Int?
    private var _countText: String?
    private var _countLabel = UILabel()
    
    private var _bucketIndex = 0
    
    init(count: Int) {
        super.init(frame: CGRectZero)
        
        _count = count
        _bucketIndex = GDefaultClusterMarkerIconView.bucketIndexForCount(count)
        _countText = GDefaultClusterMarkerIconView.textForCount(count)
        
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = true
        
        setupLabel()
        setCount(count)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
   
    func centerRect(rect:CGRect, center: CGPoint) -> CGRect {
        let r = CGRect(x: center.x - rect.size.width/2.0, y: center.y - rect.size.height/2.0, width: rect.size.width, height: rect.size.height)
        return r
    }
    
    func rectCenter(rect: CGRect) -> CGPoint {
        return CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect));
    }
    
    func setupLabel() {
        _countLabel.backgroundColor = UIColor.clearColor()
        _countLabel.textColor = UIColor.whiteColor()
        _countLabel.textAlignment = NSTextAlignment.Center
        _countLabel.adjustsFontSizeToFitWidth = true
        _countLabel.numberOfLines = 1
        
        let fontSize = CGFloat(13 + _bucketIndex)
        _countLabel.font = UIFont.boldSystemFontOfSize(fontSize)
        
        _countLabel.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        
        addSubview(_countLabel)
    }
    
    func setCount(count:Int) {
        let size = CGFloat((30 + _bucketIndex) + 5 * _bucketIndex)
        
        let newBounds = CGRect(x: 0, y: 0, width: size, height: size)
        frame = centerRect(newBounds, center: self.center)
        
        let newLabelBounds:CGRect = CGRect(x: 0, y: 0, width: newBounds.size.width, height: newBounds.size.height)
        _countLabel.frame = centerRect(newLabelBounds, center: rectCenter(newBounds))
        _countLabel.text = _countText
        
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetAllowsAntialiasing(context, true)
        
        let hexColor = GDefaultClusterMarkerIconView.bucketColors[_bucketIndex]
        let innerCircleFillColor = UIColor(hexValue: hexColor)
        
        innerCircleFillColor.setFill()
        CGContextFillEllipseInRect(context, rect)
    }

}



