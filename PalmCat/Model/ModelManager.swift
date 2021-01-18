//
//  ModelManager.swift
//  PalmCat
//
//  Created by Junsung Park on 2020/11/13.
//  Copyright © 2020 Junsung Park. All rights reserved.
//
import Foundation
import CoreData
import AppKit

class ModelManager: NSObject {

    static let shared: ModelManager = ModelManager()

    func Up() -> String
    {
        let someBits: UInt8 = 0b100000
        let str = String(someBits, radix:2) //binary base
        
        return str
    }
    func Down() -> String
    {
        let someBits: UInt8 = 0b010000
        let str = String(someBits, radix:2) //binary base
        
        return str
    }
    func Left() -> String
    {
        let someBits: UInt8 = 0b001000
        let str = String(someBits, radix:2) //binary base
        
        return str
    }
    func Right() -> String
    {
        let someBits: UInt8 = 0b000100
        let str = String(someBits, radix:2) //binary base
        
        return str
    }
    func LeftUp() -> String
    {
        let someBits: UInt8 = 0b101000
        let str = String(someBits, radix:2) //binary base
        
        return str
    }
    func RightUp() -> String
    {
        let someBits: UInt8 = 0b100100
        let str = String(someBits, radix:2) //binary base
        
        return str
    }
    func LeftDown() -> String
    {
        let someBits: UInt8 = 0b011000
        let str = String(someBits, radix:2) //binary base
        
        return str
    }
    func RightDown() -> String
    {
        let someBits: UInt8 = 0b010100
        let str = String(someBits, radix:2) //binary base
        
        return str
    }
    func LeftUpCurve() -> String
    {
        let someBits: UInt8 = 0b010010
        let str = String(someBits, radix:2) //binary base
        
        return str
    }
    func RightUpCurve() -> String
    {
        let someBits: UInt8 = 0b100010
        let str = String(someBits, radix:2) //binary base
        
        return str
    }
    func LeftDownCurve() -> String
    {
        let someBits: UInt8 = 0b000110
        let str = String(someBits, radix:2) //binary base
        
        return str
    }
    func RightDownCurve() -> String
    {
        let someBits: UInt8 = 0b001010
        let str = String(someBits, radix:2) //binary base
        
        return str
    }
    func LeftDownRightDownCurve() -> String
    {
        let someBits: UInt8 = 0b011010
        let str = String(someBits, radix:2) //binary base
        
        return str
    }
    func LeftUpRightUpCurve() -> String
    {
        let someBits: UInt8 = 0b010110
        let str = String(someBits, radix:2) //binary base
        
        return str
    }
    func RightDownLeftDownCurve() -> String
    {
        let someBits: UInt8 = 0b101010
        let str = String(someBits, radix:2) //binary base
        
        return str
    }
    func RightUpLeftUpCurve() -> String
    {
        let someBits: UInt8 = 0b100110
        let str = String(someBits, radix:2) //binary base
        
        return str
    }


}
