//
//  NotificationsWidget.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 25.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import UIKit
import QuartzCore

/**
* Shows yellow widget with number
*
* @author Alexander Volkov
* @version 1.0
*/
@IBDesignable
public class NotificationsWidget: UIView {
    
    @IBInspectable var CORDER_RADIUS: CGFloat = 7
    
    @IBInspectable public var additionalWidth: CGFloat = 0
    
    // Change this number then notifications number is changed
    @IBInspectable public var number: Int = 5 {
        didSet {
            if number > 999 {
                additionalWidth = 12
            }
            else if number > 99 {
                additionalWidth = 6
            }
            else if number > 9 {
                additionalWidth = 2
            }
            else {
                additionalWidth = 0
            }
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var bgColor = Colors.yellow
    @IBInspectable var textColor = UIColor.whiteColor()
    
    var textField: UITextField?
    
    override public func drawRect(rect: CGRect) {
        
        let c = UIGraphicsGetCurrentContext()
        
        // DO not paint red background if number is zero
        if number > 0 {
            let borderBounds = getCircleBounds()
            
            CGContextSetFillColorWithColor(c , bgColor.CGColor)
            let path = CGPathCreateWithRoundedRect(borderBounds, CORDER_RADIUS, CORDER_RADIUS, nil)
            CGContextAddPath(c, path)
            CGContextFillPath(c)
        }
        
    }
    
    private func drawCircleInBounds(bounds: CGRect) {
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutNumber()
        self.userInteractionEnabled = false
    }
    
    private func getCircleBounds() -> CGRect {
        return CGRect(x: bounds.width/2 - CORDER_RADIUS - additionalWidth/2, y: bounds.height/2 - CORDER_RADIUS, width: CORDER_RADIUS * 2 + additionalWidth, height: CORDER_RADIUS * 2)
    }
    
    private func layoutNumber() {
        let bounds = getCircleBounds()
        
        if textField == nil {
            textField = UITextField(frame: bounds)
            textField?.textAlignment = NSTextAlignment.Center
            textField?.textColor = textColor
            textField?.font = UIFont(name: Fonts.regular, size: 12)
            textField?.enabled = false
            self.addSubview(textField!)
        }
        textField?.text = "\(number)"
        textField?.frame = bounds
        // DO not show number if the number is zero or less
        textField?.hidden = (number <= 0)
    }
}
