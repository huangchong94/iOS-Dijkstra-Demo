//
//  ViewController.swift
//  DPath
//
//  Created by 黄翀 on 16/6/1.
//  Copyright © 2016年 黄翀. All rights reserved.
//

import UIKit

struct PathColor {
    var sourceColor = UIColor.orangeColor()
    var nodeColor = UIColor.clearColor()
    var lineColor = UIColor.blackColor()
}
class ViewController: UIViewController {
    var data = [[String]]()
    var pathNames: [[String?]] {
        return data.map {
            return $0.map {
                return $0 != "#" ? $0 : nil
            }
        }
    }
    
    var nodeNames: [String] {
        return data.indices.map { return "\($0+1)" }
    }

    @IBOutlet var startTextField: UITextField! {
        didSet {
            startTextField.text = nodeNames[0]
            startTextField.delegate = self
        }
    }
    @IBOutlet var endTextField: UITextField! {
        didSet {
            endTextField.text = nodeNames[0]
            endTextField.delegate = self
        }
    }
    @IBOutlet var graphView: GraphView!
    @IBOutlet var previousStepButton: UIButton!
    @IBOutlet var nextStepButton: UIButton!
    @IBOutlet var showPathButton: UIButton!
    @IBOutlet var distanceLabel: UILabel! {
        didSet {
            distanceLabel.lineBreakMode = .ByWordWrapping
        }
    }
    
    var startIndex: Int {
        return nodeNames.indexOf(startTextField.text!)!
    }
    var endIndex: Int {
        return nodeNames.indexOf(endTextField.text!)!
    }
    
    var pathFinder: Dijkstra!
    var history: ([[PathInfo?]], [Int])!
    var pathsInfo: [PathInfo?]!
    override func viewDidLoad() {
        super.viewDidLoad()
        let graphInfo = GraphInfo(nodeNames: nodeNames, pathNames: pathNames)
        graphView.graphInfo = graphInfo
       // graphView.isOriented = true
        let graph = convertPahtNamesToGraph()
        pathFinder = Dijkstra(graph: graph, startPoint: startIndex)
    }
    
    var shouldReplaceNodes = true
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if shouldReplaceNodes
        {
            graphView.placeTheNodes()
            graphView.setNeedsDisplay()
            shouldReplaceNodes = false
        }
    }
    let selectedPathColor = PathColor(sourceColor: UIColor.orangeColor(), nodeColor: UIColor.orangeColor(), lineColor: UIColor.orangeColor())
    
    
    private var historyIndex = -1
    private var didDyeNode = false
    @IBAction func nextStep(sender: UIButton) {
        //点击开始
        if historyIndex == -1 {
            pathsInfo = pathFinder.findPath()
            history = pathFinder.history()
            graphView.dyeNode(startIndex, color: UIColor.orangeColor())
            previousStepButton.enabled = true
            nextStepButton.setTitle("更新源点到各点路径", forState: .Normal)
            historyIndex += 1
            didDyeNode = true
        }
        else //后续步骤
        {
            if didDyeNode {
                graphView.resetColor()
                for case let pathInfo? in history.0[historyIndex] { dyePath(pathInfo) } //为更新路径染色 显示待选路径 距离
                displayCandiates(historyIndex)
                historyIndex += 1
                didDyeNode = false
                nextStepButton.setTitle("选择最短路径", forState: .Normal)
            }
            else {
                dyeNode(historyIndex)  //选择最短路径，显示最短距离
                didDyeNode = true
            }
            if historyIndex == history.0.count {
                nextStepButton.setTitle("寻路完毕", forState: .Normal)
                nextStepButton.enabled = false
                distanceLabel.text = "最短路线为橙色路线"
            }
        }
    }
    
    @IBAction func previousStep(sender: UIButton) {
        historyIndex -= 1
        if historyIndex == -1 {
            graphView.dyeNode(startIndex, color: UIColor.clearColor())
            previousStepButton.enabled = false
            nextStepButton.setTitle("开始", forState: .Normal)
        }
        else {
            if didDyeNode {
                historyIndex += 1
                dyeNode(historyIndex, select: false) //取消选择
                didDyeNode = false
                nextStepButton.setTitle("选择最短路径", forState: .Normal)
                displayCandiates(historyIndex-1)
            }
            else {
                graphView.resetColor()
                if historyIndex == 0 {
                    graphView.dyeNode(startIndex, color: UIColor.orangeColor())
                }
                else {
                    for case let pathInfo? in history.0[historyIndex-1] { dyePath(pathInfo) }
                }
                didDyeNode = true
                nextStepButton.setTitle("更新源点到各点路径", forState: .Normal)
                let end = history.1[historyIndex]
                displayMinimumDistance(historyIndex, end: end)
            }
        }
        nextStepButton.enabled = true
    }
    
    
    var didShowPathDirectly = false
    @IBAction func showPath(sender: UIButton) {
        if !didShowPathDirectly {
            pathsInfo = pathFinder.findPath()
            history = pathFinder.history()
            graphView.resetColor()
            dyeAllPaths()
            didShowPathDirectly = true
            
            showPathButton.setTitle("重置", forState: .Normal)
            previousStepButton.enabled = false
            nextStepButton.enabled = false
            nextStepButton.setTitle("寻路完毕", forState: .Normal)
            displayMinimumDistance(history.0.count-1, end: history.1.last!)
        }
        else {
            didShowPathDirectly = false
            restart()
        }
    }
    
    private func dyeNode(stepCount: Int, select: Bool = true)
    {
        let end = history.1[stepCount]
        let count = history.0[stepCount][end]!.path.count
        let start = history.0[stepCount][end]!.path[count-2]
        let color = select ? UIColor.orangeColor() : UIColor.blueColor()
        graphView.dyeNode(end, color: color)
        graphView.dyeLine(start, end: end, color: color)
        didDyeNode = true
        nextStepButton.setTitle("更新源点到各点路径", forState: .Normal)
        if select {
            displayMinimumDistance(history.0.count-1, end: end)
        }
        else {
            distanceLabel.text = nil
        }
    }
    
    private func convertPahtNamesToGraph() -> [[Double?]]
    {
        var result: [[Double?]] = Array(count: pathNames.count, repeatedValue: Array(count: pathNames.count, repeatedValue: 0))
        let formatter = NSNumberFormatter()
        for i in pathNames.indices
        {
            for j in pathNames.indices
            {
                if let pathName = pathNames[i][j] where i != j
                {
                    result[i][j] = formatter.numberFromString(pathName)!.doubleValue
                }
                else
                {
                    result[i][j] = nil
                }
            }
        }
        
        
        return result
    }
    
    private func dyeAllPaths()
    {
        
        for case let pathInfo? in pathsInfo { dyePath(pathInfo, pathColor: selectedPathColor) }
    }
    
    private func dyePath(pathInfo: PathInfo, pathColor: PathColor? = nil)
    {
        let path = pathInfo.path
        graphView.dyeNode(path.first!, color: UIColor.orangeColor())
        
        var start = path.first!
        path.dropFirst().forEach {
            if let color = pathColor {
                graphView.dyeNode($0, color: color.nodeColor)
                graphView.dyeLine(start, end: $0, color: color.lineColor)
            }
            else {
                let endIsSelected = history.1[0...historyIndex].contains($0)
                if endIsSelected
                {
                    graphView.dyeNode($0, color: UIColor.orangeColor())
                    graphView.dyeLine(start, end: $0, color: UIColor.orangeColor())//如果是已选择的点涂上橙色
                }
                else
                {
                    graphView.dyeNode($0, color: UIColor.blueColor())
                    graphView.dyeLine(start, end: $0, color: UIColor.blueColor())//否则涂上蓝色
                }
            }
            start = $0
        }
    }
    
    private func restart()
    {
        pathFinder.startPoint = startIndex
        historyIndex = -1
        updateUIForRestart()
    }
    private func updateUIForRestart()
    {
        graphView.resetColor()
        
        showPathButton.setTitle("直接显示路径", forState: .Normal)
        previousStepButton.enabled = false
        nextStepButton.enabled = true
        nextStepButton.setTitle("开始", forState: .Normal)
        distanceLabel.text = nil
    }
    
    private func displayMinimumDistance(index: Int, end: Int)
    {
        let pathsInfo = history.0[index]
        let startName = graphView.graphInfo.nodeNames[startIndex]
        let endName = graphView.graphInfo.nodeNames[end]
        distanceLabel.text = "\(startName)到\(endName)的最短距离为\(pathsInfo[end]!.distance)"
    }
    
    private func displayCandiates(index: Int)
    {
        let pathsInfo = history.0[index]
        
        var i = 0
        let text = pathsInfo.indices.filter { //过滤已选择节点,路径不存在的点和起点
            return !(history.1[0...index].contains($0) || $0 == startIndex || pathsInfo[$0] == nil)
        }.map {
            return ($0, pathsInfo[$0]!.distance)
            }.reduce("") {
                i += 1
                if i % 3 == 0
                {
                    return $0 + "  \(nodeNames[startIndex])➔\(nodeNames[$1.0])距离为\($1.1)\n"
                }
                return $0 + "  \(nodeNames[startIndex])➔\(nodeNames[$1.0])距离为\($1.1)"
        }
        distanceLabel.text = text
    }
}

extension ViewController: UITextFieldDelegate
{
    func textFieldDidEndEditing(textView: UITextField) {
        if textView === startTextField {
            restart()
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
