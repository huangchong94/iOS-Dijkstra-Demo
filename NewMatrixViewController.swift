//
//  NewMatrixViewController.swift
//  DPath
//
//  Created by 黄翀 on 16/6/2.
//  Copyright © 2016年 黄翀. All rights reserved.
//

import UIKit

class NewMatrixViewController: UIViewController {

    @IBOutlet var matrixView: ScrollableMatrixView!
    @IBOutlet var promptLabel: UILabel!
    @IBAction func addNode(sender: UIButton) {
        matrixView.rowCount += 1
        matrixView.columnCount += 1
        for i in 0..<matrixView.rowCount {
            let nodeCount = matrixView.rowCount
            matrixView[i, nodeCount-1] = "#"
            matrixView[nodeCount-1, i] = "#"
            matrixView[nodeCount-1, nodeCount-1] = "0"
        }
        promptLabel.text = "\(matrixView.rowCount)" + "×" + "\(matrixView.rowCount)"
    }
    
    @IBAction func deleteNode(sender: UIButton) {
        matrixView.rowCount -= 1
        matrixView.columnCount -= 1
        promptLabel.text = "\(matrixView.rowCount)" + "×" + "\(matrixView.rowCount)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0 ..< matrixView.rowCount {
            for j in 0 ..< matrixView.rowCount {
                if i == j {
                    matrixView[i, j] = "0"
                }
                else {
                    matrixView[i, j] = "#"
                }
            }
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        matrixView.adJustMatrixOrigin()
        print(matrixView.contentOffset, matrixView.contentSize, matrixView.contentInset)
    }
    lazy var elementFormatter: ElementFormatter = {
        let formatter = ElementFormatter(matrixView: self.matrixView)
        self.matrixView.positionDelegate = formatter
        return formatter
    }()
    
    @IBAction func inputNumber(sender: UIButton) {
        setData(elementFormatter.inputDigit(sender.currentTitle!))
    }
    
    @IBAction func inputDecimalPoint(sender: UIButton) {
        setData(elementFormatter.inputDecimalPoint())
    }
    
    @IBAction func backSpace(sender: UIButton) {
        setData(elementFormatter.backSpace())
    }
    @IBAction func inputSharp(sender: UIButton) {
        setData(elementFormatter.inputSharp())
    }
    
    private func setData(data: String)
    {
        let x = matrixView.currentPosition.0
        let y = matrixView.currentPosition.1
        matrixView[x, y] = data
        matrixView[y, x] = data
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ViewController where segue.identifier == "graph"
        {
            vc.data = matrixView.getAllData()
        }
    }
    

}
