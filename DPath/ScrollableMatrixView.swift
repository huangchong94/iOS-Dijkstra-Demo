//
//  ScrollableMatrixView.swift
//  Scroll View
//
//  Created by 黄翀 on 16/4/3.
//  Copyright © 2016年 黄翀. All rights reserved.
//

import UIKit


@IBDesignable class ScrollableMatrixView: UIScrollView {
    
    weak var positionDelegate: MatrixViewDelegate? {
        get{return matrixView.delegate}
        set {
            matrixView.delegate = newValue
        }
    }
    override var frame: CGRect {
        didSet {
            adJustMatrixOrigin()
        }
    }
    
    @IBInspectable var rowCount: Int {
        get {
            return matrixView.rowCount
        }
        set {
            matrixView.rowCount = newValue
            adJustMatrixOrigin()
        }
    }
    @IBInspectable var columnCount: Int {
        get {
            return matrixView.columnCount
        }
        set {
            matrixView.columnCount = newValue
            adJustMatrixOrigin()
        }
    }
    var matrixSize: CGSize {
        return matrixView.size
    }
    var currentPosition: (Int, Int) {
        get {
            return (matrixView.row, matrixView.column)
        }
        set {
            matrixView.row = newValue.0
            matrixView.column = newValue.1
            positionDelegate?.rowPositionDidChange(matrixView)
            positionDelegate?.columnPositionDidChange(matrixView)
        }
    }
    
    var allowEditing: Bool {
        get {
            return matrixView.allowEditing
        }
        set {
            matrixView.allowEditing = newValue
        }
    }
    private let matrixView: MatrixView
    override func intrinsicContentSize() -> CGSize {
        return self.frame.size
    }
    func  getAllData() -> [[String]] {
        var data = Array(count: rowCount, repeatedValue: Array(count: columnCount, repeatedValue: " "))
       
        for i in 0 ..< rowCount*columnCount
        {
            let c = i % columnCount
            let r = i / columnCount
            data[r][c] = matrixView[r, c]
        }
        return data
    }
  
    func setData(data: [[String]]) {
        matrixView.setAllData(data)
    }
    
    func setCurrentPositionText(text: String) {
        matrixView[currentPosition.0, currentPosition.1] = text
    }
    
    func getCurrentPositionText() -> String {
        return matrixView[currentPosition.0, currentPosition.1]
    }
    
    init?(frame: CGRect, row: Int, column: Int)
    {
        guard row>0&&column>0
            else
        {
            return nil
        }
        matrixView = MatrixView(row: row, column: column)!
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        matrixView = MatrixView(row: 2, column: 2)!
        print("before coder", matrixView.frame)
        super.init(coder: aDecoder)   // set frame
        print("sFrame = ", matrixView.frame)
        configure()
        print("after config sFrame = ", matrixView.frame)

    }
    
    override init(frame: CGRect) {
        matrixView = MatrixView(row: 2, column: 2)!
        super.init(frame: frame)
        configure()
    }

    
    private func computeMatrixViewFrame() -> CGRect
    {
        let y: CGFloat = 0
        var x: CGFloat = 0
        if matrixSize.width < bounds.width
        {
            x = (bounds.width - matrixSize.width) / 2
        }
        else
        {
            x = bounds.width * 0.2
        }
        return CGRect(x: x, y: y, width: matrixSize.width, height: matrixSize.height)
    }
    
    
    func adJustMatrixOrigin() {
        matrixView.frame = computeMatrixViewFrame()
        let dy = matrixView.size.height - bounds.height
        
        if matrixView.size.height > bounds.height
        {
            let rect = CGRectMake(frame.origin.x, dy, frame.size.width, frame.size.height)
            scrollRectToVisible(rect, animated: true)
        }
        
        let dx = matrixView.size.height - bounds.height
        
        if matrixView.size.width > bounds.width
        {
            let rect = CGRectMake(dx, frame.origin.y, frame.size.width, frame.size.height)
            scrollRectToVisible(rect, animated: true)
        }
    }
    private func configure()
    {
        matrixView.backgroundColor = UIColor.clearColor()
        addSubview(matrixView)
        let width = max(matrixSize.width, bounds.width)
        let height = max(matrixSize.height, bounds.height)
        contentSize = CGSize(width: width, height: height)
    }
    func configureMatrixFrame()
    {
        let y: CGFloat = 0
        var x: CGFloat = 0
        if matrixSize.width < bounds.width
        {
            x = (bounds.width - matrixSize.width) / 2
        }
        else
        {
            x = bounds.width * 0.2
        }
        matrixView.frame = CGRect(x: x, y: y, width: matrixSize.width, height: matrixSize.height)
        print(matrixView.frame)
    }
    subscript(i: Int, j: Int) -> String {
        get {
            return matrixView[i, j]
        }
        set {
            guard allowEditing
                else
            {
                return
            }
            matrixView[i, j] = newValue
        }
    }
}




