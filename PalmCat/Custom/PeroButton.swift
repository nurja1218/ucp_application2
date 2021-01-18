//
//  PeroButton.swift
//  PalmCat
//
//  Created by Junsung Park on 2020/10/29.
//  Copyright © 2020 Junsung Park. All rights reserved.
//

import Cocoa

class PeroButton: NSButton {

    
    public var buttonColor: NSColor = NSColor(calibratedRed: 0.201, green: 0.404, blue: 0.192, alpha: 1)
    
    public var onClickColor: NSColor = NSColor(calibratedRed: 0.304, green: 0.601, blue: 0.294, alpha: 1)
    
    public var textColor: NSColor = NSColor.white
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        
           let rectanglePath = NSBezierPath(rect: NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        
           var fillColor: NSColor
           var strokeColor: NSColor
           
           rectanglePath.fill()
           
           if self.isHighlighted {
               strokeColor = self.buttonColor
               fillColor = self.onClickColor
           } else {
               strokeColor = self.onClickColor
               fillColor = self.buttonColor
           }
        
           strokeColor.setStroke()
           rectanglePath.lineWidth = 5
           rectanglePath.stroke()
           fillColor.setFill()
           rectanglePath.fill()
           bezelStyle = .shadowlessSquare
        
           let textRect = NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
           let textTextContent = self.title
           let textStyle = NSMutableParagraphStyle()
           textStyle.alignment = .center
           
           let textFontAttributes : [ NSAttributedString.Key : Any ] = [
             .font: NSFont(name: "Helvetica", size: NSFont.systemFontSize)!,
             .foregroundColor: textColor,
             .paragraphStyle: textStyle
           ]

           let textTextHeight: CGFloat = textTextContent.boundingRect(with: NSSize(width: textRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: textFontAttributes).height
           let textTextRect: NSRect = NSRect(x: 0, y: -3 + ((textRect.height - textTextHeight) / 2), width: textRect.width, height: textTextHeight)
           NSGraphicsContext.saveGraphicsState()
           textTextContent.draw(in: textTextRect.offsetBy(dx: 0, dy: 3), withAttributes: textFontAttributes)
           NSGraphicsContext.restoreGraphicsState()
    }
    
}
