//
//  MatrixView.swift
//  new
//
//  Created by 黄翀 on 16/4/30.
//  Copyright © 2016年 黄翀. All rights reserved.
//

import UIKit

protocol MatrixViewDelegate: class {
    func rowPositionDidChange(matrixView: MatrixView)
    func columnPositionDidChange(matrixView: MatrixView)
}

@IBDesignable class MatrixView: UIView {
    private var data = [["0", "0"], ["0", "0"]]
    
    var rowCount: Int
        {
        get {
            return data.count
        }
        set {
            addRows(newValue-rowCount)
        }
    }
    var columnCount: Int
        {
        get {
            if data.isEmpty {
                return 0
            }
            return data.first!.count
        }
        set {
            addColumns(newValue-columnCount)
        }
    }
    
    var row = 0 {
        didSet {
            if !allowEditing {
                return
            }
            if row >= rowCount
            {
                row = oldValue
            }
            if row != oldValue {
                delegate?.rowPositionDidChange(self)
                setNeedsDisplay()
            }
        }
    }
    
    var column = 0 {
        didSet {
            if !allowEditing {
                return
            }
            if column >= columnCount
            {
                column = oldValue
            }
            if column != oldValue {
                delegate?.columnPositionDidChange(self)
                setNeedsDisplay()
            }
        }
    }
    
    weak var delegate: MatrixViewDelegate?
    var allowEditing = true
    
    func setAllData(data: [[String]])
    {
        self.data = data
        updateWholeDisplay()
    }
    override func drawRect(rect: CGRect)
    {
        drawBracket()
        for (i, numbers) in data.enumerate()
        {
            for (j, number) in numbers.enumerate()
            {
                drawText(number, i: i, j: j)
                let origin = ijthOrigin(i, column: j)
                
                if i == row && j == column && allowEditing
                {
                    drawUnderscore(CGPointMake(origin.x, origin.y+rectSize.height))
                }
            }
        }
    }
    
    private func drawBracket()
    {
        let lPath = UIBezierPath()
        lPath.moveToPoint(CGPointMake(12, 2))
        lPath.addLineToPoint(CGPointMake(1, 2))
        lPath.addLineToPoint(CGPointMake(1, size.height-2))
        lPath.addLineToPoint(CGPointMake(12, size.height-2))
        
        let rPath = UIBezierPath()
        rPath.moveToPoint(CGPointMake(size.width-12, 2))
        rPath.addLineToPoint(CGPointMake(size.width-1, 2))
        rPath.addLineToPoint(CGPointMake(size.width-1, size.height-2))
        rPath.addLineToPoint(CGPointMake(size.width-12, size.height-2))
        
        UIColor.grayColor().setStroke()
        lPath.stroke()
        rPath.stroke()
    }
    private func drawText(text: String, i: Int, j: Int)
    {
        let attributes = [NSForegroundColorAttributeName: UIColor.blackColor(),
                          NSFontAttributeName: UIFont.systemFontOfSize(15)]
        let str = text as NSString
        
        let actualSize = str.sizeWithAttributes(attributes)
        let dx = (actualSize.width - rectSize.width) / 2
        let dy = (actualSize.height - rectSize.height) / 2
        let rect = CGRect(origin: ijthOrigin(i, column: j), size: rectSize).offsetBy(dx: -dx, dy: -dy)

        text.drawInRect(rect, withAttributes: attributes)
    }

    private func drawUnderscore(startpoint: CGPoint)
    {
        let path = UIBezierPath()
        path.moveToPoint(startpoint)
        path.addLineToPoint(CGPointMake(startpoint.x+rectSize.width, startpoint.y))
        UIColor.blueColor().setStroke()
        path.stroke()
    }
    
    
    private let unitWidth: CGFloat = 15
    private let unitHeight: CGFloat = 18
    private let leadingSpace: CGFloat = 25
    private let verticalSpacing: CGFloat = 30
    private var rectSize: CGSize {
        return CGSize(width: CGFloat(currrentMaxLength)*unitWidth, height: unitHeight) // 文字框
    }
    var size: CGSize {
        get {
            return CGSize(width: rectSize.width*CGFloat(columnCount)+leadingSpace*2, height: rectSize.height*CGFloat(rowCount)+verticalSpacing*2)
        }
        set {
            if let scrollView = superview as? UIScrollView {
                scrollView.contentSize = newValue
            }
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if data.isEmpty
        {
            return
        }
        if let touch = touches.first
        {
            guard allowEditing
                else
            {
                return
            }
            let tuple = pointToXY(touch.locationInView(self))
            row = tuple.1
            column = tuple.0
        }
    }
    
    private func pointToXY(point: CGPoint) -> (Int, Int)
    {
        let p = CGPointMake(point.x-leadingSpace, point.y-verticalSpacing)
        let x = min(max(0, Int(p.x / rectSize.width)), columnCount-1)
        let y = min(max(0, Int(p.y / rectSize.height)), rowCount-1)
        return (x, y)
    }
    
    init?(row: Int, column: Int)
    {
        guard row>0&&column>0
            else
        {
            return nil
        }
        
        super.init(frame: CGRectZero)
        self.data = generateData(row, j: column)
        self.frame = CGRect(origin: CGPointZero, size: size)
        (superview as? UIScrollView)?.contentSize = size
    }
    
    init?(data: [[String]])
    {
        guard !data.isEmpty
            else
        {
            return nil
        }
        
        self.data = data
        super.init(frame: CGRectZero)
        self.frame = CGRect(origin: CGPointZero, size: size)
        (superview as? UIScrollView)?.contentSize = size
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureAccording2Frame(frame)
    }
  
    private func configureAccording2Frame(frame: CGRect)
    {
        let width = size.width - 2*leadingSpace
        let height = size.height - 2*verticalSpacing
        let c = Int(ceil(width/unitWidth))
        let r = Int(ceil(height/unitHeight))
        self.data = generateData(r, j: c)
        (superview as? UIScrollView)?.contentSize = size
    }
    
    private func generateData(i: Int, j: Int) -> [[String]]
    {
        return Array(count: i, repeatedValue: Array(count: j, repeatedValue: "0"))
    }
    
    
    
    private func addRows(n: Int)
    {
        if n > 0
        {
            data.appendContentsOf(Array(count: n, repeatedValue: Array(count: columnCount, repeatedValue: "0")))
        }
        else if n < 0
        {
            let deleteCount = min(abs(n), rowCount-1)
            for _ in 0 ..< deleteCount {
                data.removeLast()
            }
        }
        updateFocusifNeeded()
        updateWholeDisplay()
    }
    
    private func addColumns(n: Int)
    {
        if n > 0 {
            for _ in 0 ..< n {
                for i in data.indices {
                    data[i].append("0")
                }
            }
        }
        else if n < 0 {
            let deleteCount = min(abs(n), columnCount-1)
            for _ in 0 ..< deleteCount {
                for j in 0 ..< rowCount {
                    data[j].removeLast()
                }
            }
        }
        updateFocusifNeeded()
        updateWholeDisplay()
    }
    
    private func updateFocusifNeeded()
    {
        if row >= rowCount {
            row = rowCount - 1
        }
        if column >= columnCount {
            column = columnCount - 1
        }
    }
    
    func updateDisplayForTextChange(row: Int, column: Int)
    {
        guard maxLength == currrentMaxLength
            else
        {
            currrentMaxLength = maxLength
            updateWholeDisplay()
            return
        }
        updateDisplayForithRect(row, j: column)
    }
    
    private func updateDisplayForithRect(i: Int, j: Int)
    {
        setNeedsDisplayInRect(CGRect(origin: ijthOrigin(i, column: j), size: rectSize))
    }
    private func updateWholeDisplay()
    {
        currrentMaxLength = maxLength
        let origin = frame.origin
        frame = CGRect(origin: origin, size: size)
        if let scrollView  = superview as? UIScrollView {
            scrollView.contentSize = size
            scrollView.contentInset.right = origin.x
        }
        setNeedsDisplay()
    }
    private var currrentMaxLength = 1
    
    private var maxLength: Int {
        if data.isEmpty {
            return 0
        }
        return data.map {
            $0.map {$0.characters.count}.maxElement()!
            }.maxElement()!
    }
    
    private func ijthOrigin(row: Int, column: Int) -> CGPoint {
        return CGPointMake(CGFloat(column)*rectSize.width+leadingSpace, CGFloat(row)*rectSize.height+verticalSpacing)
    }
    
    
    
    subscript(i: Int, j: Int) -> String {
        get {
            return data[i][j]
        }
        set {
            guard allowEditing
                else
            {
                return
            }
            data[i][j] = newValue
            updateDisplayForTextChange(i, column: j)
        }
    }
}



