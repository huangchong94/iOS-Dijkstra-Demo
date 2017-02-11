//
//  GraphView.swift
//  DPath
//
//  Created by 黄翀 on 16/6/2.
//  Copyright © 2016年 黄翀. All rights reserved.
//

import UIKit

struct GraphInfo {
    var nodeNames = [String]()
    var pathNames = [[String?]]()
}

class GraphView: UIView {
    var graphInfo = GraphInfo() {
        didSet {
            configureForGraphInfo()
            placeTheNodes()
            setNeedsDisplay()
        }
    }
    var isOriented = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var nodeCoordinates = [CGPoint]()
    
    func dyeNode(index: Int, color: UIColor)
    {
        nodeColor[index] = color
        setNeedsDisplay()
    }
    func dyeLine(start: Int, end: Int, color: UIColor)
    {
        pathColor[start][end] = color
        if !isOriented {
            pathColor[end][start] = color
        }
        setNeedsDisplay()
    }
    
    func resetColor()
    {
        nodeColor = Array(count: self.graphInfo.nodeNames.count, repeatedValue: UIColor.clearColor())
        let array = Array(count: self.graphInfo.nodeNames.count, repeatedValue: UIColor.blackColor())
        pathColor = Array(count: self.graphInfo.nodeNames.count, repeatedValue: array)
        setNeedsDisplay()
    }
    
    private var nodeColor = [UIColor]()
    private var pathColor = [[UIColor]]()
    override func drawRect(rect: CGRect)
    {
        UIColor.blackColor().setStroke()
        //节点
        nodeCoordinates.enumerate().forEach {
            nodeColor[$0.0].setFill()
            let circle = UIBezierPath.circle($0.1, radius: radius)
            circle.fill()
            circle.stroke()
            
            let nodeName = graphInfo.nodeNames[$0.0] as NSString
            let length = 2*radius / 1.414 //根号2
            //节点名
            nodeName.drawInRect(CGRect.rect($0.1, width: length, height: length), withAttributes: [NSForegroundColorAttributeName: UIColor.blackColor()])
        }
        
        //路线
        
        for i in graphInfo.pathNames.indices
        {
            if !isOriented
            {
                for j in graphInfo.pathNames.indices[i+1..<graphInfo.nodeNames.count]
                {
                    let (start, end) = configureForPath(i, end: j)
                    if let nameStr = graphInfo.pathNames[i][j] where i != j
                    {
                        drawPathName(nameStr, start: start, end: end)
                        pathColor[i][j].setStroke()
                        UIBezierPath.line(start, endPoint: end).stroke()
                    }
                }
            }
            else
            {
                for j in graphInfo.pathNames.indices where j != i
                {
                    if let nameStr = graphInfo.pathNames[i][j]
                    {
                        print(i, j, nameStr)
                        let (start, end) = configureForPath(i, end: j)
                        let color = pathColor[i][j]
                        color.setStroke()
                        if i < j {
                            if color == UIColor.blueColor() {
                                print("blue")
                            }
                            else {
                                print("black")
                            }
                            drawPathName(nameStr, start: start, end: end)
                            UIBezierPath.line(start, endPoint: end).stroke()
                            drawArrowAtPoint(end, direction: (start, end), color: color)
                        }
                        else {
                            print(i, j)
                            let path = UIBezierPath()
                            path.moveToPoint(start)
                            let controlPoint = configureControlPoint(start, end: end)
                            path.addQuadCurveToPoint(end, controlPoint: controlPoint)
                            path.stroke()
                            drawArrowAtPoint(controlPoint, direction: (start, end), color: color)
                        }
                    }
                }
            }
        }
    }
    
    private var pathNameWidth: CGFloat = 20
    private var pathNameHeight: CGFloat = 10
    private var pathNameVerticalOffset: CGFloat = 3
    private func drawPathName(pathName: String, start: CGPoint, end: CGPoint)
    {
        var origin: CGPoint
        let dx = (end.x - start.x) >= 0
        let dy = (end.y - start.y) >= 0
        let isPositive = dx && dy
        let midX = start.x/2 + end.x/2
        let midY = start.y/2 + end.y/2
        
        let y = midY - pathNameHeight - pathNameVerticalOffset
        if isPositive
        {
            origin = CGPoint(x: midX, y: y)
        }
        else
        {
            origin = CGPoint(x: midX-pathNameWidth, y: y)
        }
        
        let rect = CGRect(origin: origin, size: CGSize(width: pathNameWidth, height: pathNameHeight+5))
        pathName.drawInRect(rect, withAttributes: [NSForegroundColorAttributeName: UIColor.blackColor()])
    }
    
    private func configureForPath(start: Int, end: Int) -> (CGPoint, CGPoint)
    {
        let startCenter = nodeCoordinates[start]
        let endCenter = nodeCoordinates[end]
        let dx = endCenter.x - startCenter.x
        let dy = endCenter.y - startCenter.y
        let ratio = radius / startCenter.distanceTo(endCenter)
        
        let sdx = dx * ratio
        let sx = startCenter.x + sdx
        let sdy = dy * ratio
        let sy = startCenter.y + sdy
        let startP = CGPoint(x: sx, y: sy)
        
        let ex = endCenter.x - sdx
        let ey = endCenter.y - sdy
        let endP = CGPoint(x: ex, y: ey)
        
        return (startP, endP)
    }
    
    private let controlRatio: CGFloat = 0.3
    private func configureControlPoint(start: CGPoint, end: CGPoint) -> CGPoint
    {
        let (length, sin, cos) = computeLSinCos((end.x-start.x, end.y-start.y))
        let midX = start.x/2 + end.x/2
        let midY = start.y/2  + end.y/2
        
        let newLength = length*controlRatio
        let newX = newLength*cos
        let newY = newLength*sin
        
        let (dx, dy) = rotateVector((newX, newY), radian: CGFloat(M_PI/2))
        return CGPoint(x: midX+dx, y: midY+dy)
    }
    
    private let arrowRadian: CGFloat = CGFloat(M_PI) / 6
    private func drawArrowAtPoint(point: CGPoint, direction:(CGPoint, CGPoint), color: UIColor)
    {
        let dx = direction.1.x - direction.0.x
        let dy = direction.1.y - direction.0.y
        let (_, sin, cos) = computeLSinCos((dx, dy))
        
        let newX = -radius*cos
        let newY = -radius*sin
        
        color.setStroke()
        let (dx1, dy1) = rotateVector((newX, newY), radian: arrowRadian)
        let path1EndPoint = CGPoint(x: point.x+dx1, y: point.y+dy1)
        UIBezierPath.line(point, endPoint: path1EndPoint).stroke()
        
        let (dx2, dy2) = rotateVector((newX, newY), radian: -arrowRadian)
        let path2EndPoint = CGPoint(x: point.x+dx2, y: point.y+dy2)
        UIBezierPath.line(point, endPoint: path2EndPoint).stroke()
    }
    
    private func rotateVector(vector: (CGFloat, CGFloat), radian: CGFloat) -> (CGFloat, CGFloat)
    {
        let (x, y) = vector
        let newX = x*cos(radian) - y*sin(radian)
        let newY = x*sin(radian) + y*cos(radian)
        return (newX, newY)
    }
    private func computeLSinCos(vector: (CGFloat, CGFloat)) -> (CGFloat, CGFloat, CGFloat)
    {
        let (x, y) = vector
        let length = sqrt(pow(x, 2)+pow(y, 2))
        return (length, y/length, x/length)
    }
    var sloppiness: ClosedInterval<CGFloat> {
        return (-CGFloat(1.8)*radius...CGFloat(1.8)*radius)
    }
    var chosenIndex: Int?
    func pan(gesture:UIPanGestureRecognizer) {
        let touchPoint = gesture.locationInView(self)
        
        switch gesture.state {
            case .Began:
                if let index = nodeCoordinates.indexOf ({
                    let dx = $0.x - touchPoint.x
                    let dy = $0.y - touchPoint.y
                    if sloppiness.contains(dx) && sloppiness.contains(dy)
                    {
                        return true
                    }
                    return false
                })
                {
                    chosenIndex = index
                }
            case .Changed:
                let translation = gesture.translationInView(self)
                if let index = chosenIndex
                {
                    var x = nodeCoordinates[index].x + translation.x
                    var y = nodeCoordinates[index].y + translation.y
                    x = max(radius, min(x, bounds.width-radius))
                    y = max(radius, min(y, bounds.height-radius))
                    nodeCoordinates[index] = CGPoint(x: x, y: y)
                    gesture.setTranslation(CGPointZero, inView: self)
                    setNeedsDisplay()
                }
            case .Ended:
                chosenIndex = nil
            default: break
        }
    }
    
    
    init(frame: CGRect, graphInfo: GraphInfo)
    {
        self.graphInfo = graphInfo
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    let radius: CGFloat = 10.0
    var nodesPerLine = 4
    var nodesPerColumn: Int {
        let quotient = graphInfo.nodeNames.count / nodesPerLine
        let remainder = graphInfo.nodeNames.count % nodesPerLine
        return quotient + remainder
    }
    var leadingSpace: CGFloat = 40
    var topSpacing: CGFloat = 80
    var bottomSpacing: CGFloat = 20
    var horizontalSpacing: CGFloat {
        return (bounds.width - 2*leadingSpace) / CGFloat(nodesPerLine-1)
    }
    var verticalSpacing: CGFloat {
        if nodesPerColumn > 1
        {
            return (bounds.height-topSpacing-bottomSpacing) / CGFloat(nodesPerColumn-1)

        }
        return 0
    }
    func placeTheNodes()
    {
        for i in graphInfo.nodeNames.indices
        {
            let r = i / nodesPerLine
            let c = i % nodesPerLine
            let x = startX + CGFloat(c)*horizontalSpacing
            let y = startY + CGFloat(r)*verticalSpacing
            nodeCoordinates[i] = CGPoint(x: x, y: y)
        }
    }
    private func configure()
    {
        configureForGraphInfo()
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(GraphView.pan(_:))))
        placeTheNodes()
    }
    private func configureForGraphInfo()
    {
        nodeColor = Array(count: self.graphInfo.nodeNames.count, repeatedValue: UIColor.clearColor())
        let array = Array(count: self.graphInfo.nodeNames.count, repeatedValue: UIColor.blackColor())
        pathColor = Array(count: self.graphInfo.nodeNames.count, repeatedValue: array)
        nodeCoordinates = Array(count: self.graphInfo.nodeNames.count, repeatedValue: CGPointZero)
    }
    
    private var startX: CGFloat {
        return leadingSpace
    }
    private var startY: CGFloat {
        return topSpacing
    }
    
    
}


extension UIBezierPath {
    static func circle(center: CGPoint, radius: CGFloat) -> UIBezierPath {
        return UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
    }
    
    static func line(startPoint: CGPoint, endPoint: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(startPoint)
        path.addLineToPoint(endPoint)
        return path
    }
}

extension CGRect {
    static func rect(center: CGPoint, width: CGFloat, height: CGFloat) -> CGRect {
        let x = center.x - width/2
        let y = center.y - height/2
        let origin = CGPoint(x: x, y: y)
        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }
}

extension CGPoint {
    func distanceTo(p: CGPoint) -> CGFloat
    {
        let xSquare = pow(p.x-self.x, 2)
        let ySquare = pow(p.y-self.y, 2)
        return sqrt(xSquare+ySquare)
    }
}

