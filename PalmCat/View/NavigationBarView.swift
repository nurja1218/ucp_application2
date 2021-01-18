//
//  NavigationBarView.swift
//  PalmCat
//
//  Created by Junsung Park on 2020/10/29.
//  Copyright © 2020 Junsung Park. All rights reserved.
//

import Cocoa

class NavigationBarView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

          
        NSGraphicsContext.saveGraphicsState()
        NSColor.white.setFill()
        dirtyRect.fill()
        NSColor.black.withAlphaComponent(0.2).setFill()
       // CGRect(origin: .zero, size: CGSize(width: dirtyRect.width, height: 1)).fill()
        NSGraphicsContext.restoreGraphicsState()
    }
    
}
