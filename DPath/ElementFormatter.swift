//
//  ElementFormatter.swift
//  Scroll View
//
//  Created by 黄翀 on 16/4/29.
//  Copyright © 2016年 黄翀. All rights reserved.
//

enum ComplexMode {
    case LA
    case RI
    var description: String {
        switch self
        {
            case .LA:
                return "2∠45"
            case .RI:
                return "1+2i"
        }
    }
}

import Foundation
class ElementFormatter: MatrixViewDelegate
{
    unowned var matrixView: ScrollableMatrixView
    var mode = ComplexMode.RI
    
    private var didFinishTyping = true
    func rowPositionDidChange(matrixView: MatrixView) {
        didFinishTyping = true
    }
    func columnPositionDidChange(matrixView: MatrixView) {
        didFinishTyping = true
    }
    func inputDigit(digit: String) -> String {
        let originalText = matrixView.getCurrentPositionText()
        guard !littleIDidExist
        else
        {
            return originalText
        }
        if didFinishTyping
        {
            didFinishTyping = false
            return digit
        }
        else
        {
            if originalText != "0"
            {
                return originalText + digit
            }
            else
            {
                return digit
            }
        }
    }
    
    func inputDecimalPoint() -> String {
        return inputSymbol(".", flag: shouldAddDecimalPoint)
    }
    
    func inputSeperator() -> String {
        var seperator: String
        switch mode {
        case .LA(_):
            seperator = "∠"
        default:
            seperator = "+"
        }
        
        return inputSymbol(seperator, flag: shouldAddSeperator)
    }
    
    func inputLittlei() -> String {
        return inputSymbol("i", flag: shouldAddLittleI)
    }
    
    func inputSlash() -> String {
        return inputSymbol("/", flag: shouldAddSlash)
    }
    
    func inputMinusSign() -> String
    {
        let originalText = matrixView.getCurrentPositionText()
        let characters = originalText.characters
        if characters.count == 1 && characters[originalText.startIndex] == "0"
        {
            didFinishTyping = false
            return "-"
        }
        return inputSymbol("-", flag: true)
    }
    func backSpace() -> String {
        var text = matrixView.getCurrentPositionText()
        let count = text.characters.count
        if count == 1
        {
            text = "0"
        }
        else if count > 1
        {
            text.removeAtIndex(text.endIndex.predecessor())
        }
        return text
    }
    
    func inputSharp() -> String {
        return "#"
    }
    private func inputSymbol(symbol: String, flag: Bool) -> String
    {
        
        let original = matrixView.getCurrentPositionText()
        if flag {
            return original.stringByAppendingString(symbol)
        }
        return original
    }
    private var littleIDidExist: Bool {
        if let _ = matrixView.getCurrentPositionText().characters.indexOf("i")
        {
            return true
        }
        return false
    }
    
    private var shouldAddLittleI: Bool {
        guard !littleIDidExist
        else
        {
            return false
        }
        //MARK:TODO shouldAddLittleI
        return true
    }
    private var shouldAddDecimalPoint: Bool {
        
        guard !littleIDidExist
        else {
            return false
        }
        //MARK:TODO shouldAddDecimalPoint
        return true
    }
    
    private var shouldAddSeperator: Bool {
        //MARK:TODO shouldAddSeperator
        return true
    }
    
    private var shouldAddSlash: Bool {
        //MARK:TODO shouldAddSlash
        return true
    }
    
    init(matrixView: ScrollableMatrixView)
    {
        self.matrixView = matrixView
    }
}