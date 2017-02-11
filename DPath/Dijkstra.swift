//
//  Dijkstra.swift
//  DPath
//
//  Created by 黄翀 on 16/6/4.
//  Copyright © 2016年 黄翀. All rights reserved.
//



import Foundation

struct PathInfo {
    var path: [Int]
    var distance: Double
}

struct Dijkstra {
    let graph: [[Double?]]
    var startPoint = 0 {
        didSet {
            if startPoint == oldValue {
                return
            }
            if startPoint >= graph.count {
                startPoint = graph.count - 1
            }
            else if startPoint < 0 {
                startPoint = 0
            }
            didConfigure = false
            prepareForConfigure()
        }
    }
    
    func history() -> ([[PathInfo?]], [Int])
    {
        
        return (predecessorsHistory.map {
            predecessor in
            return graph.indices.map {
                return configurePathToPoint(predecessor, endPoint: $0)
            }
        }, nodes)
    }
    
    private var predecessorsHistory = [[Int?]]()
    private var predecessors = [Int?]()
    private var nodes = [Int]()  //记录节点加入顺序
    private var pathsInfo = [PathInfo?]()
    mutating func findPath() -> [PathInfo?]
    {
        configure()
        return pathsInfo
    }
    
    mutating func pathToPoint(endPoint: Int) -> PathInfo? {
        configure()
        return pathsInfo[endPoint] != nil ? pathsInfo[endPoint] : nil
    }
    private var flag = [Bool]()
    private mutating func configure()
    {
        if didConfigure
        {
            return
        }
        //寻路
        var distances = graph[startPoint]
        while let (minDistance, newMember) = findMinimum(distances) {
            //加入新节点
            flag[newMember] = true
            nodes.append(newMember)
            //更新源点到各点距离
            for (dest, distance) in distances.enumerate() where dest != startPoint && !flag[dest]
            {
                if let dis = graph[newMember][dest] {
                    if isLess(minDistance+dis, rhs: distance) {
                        distances[dest] = minDistance + dis
                        predecessors[dest] = newMember
                    }
                }
            }
            predecessorsHistory.append(predecessors) //记录历史步骤
        }
        //生成源点到各点的最短路径，记录到pathsInfo中
        for endPoint in graph.indices
        {
            if let pathInfo = configurePathToPoint(predecessors, endPoint: endPoint)
            {
                pathsInfo[endPoint] = pathInfo
            }
            else
            {
                pathsInfo[endPoint] = nil
            }
        }
        didConfigure = true
    }
    
    private func findMinimum(array: [Double?]) -> (Double, Int)?
    {
        var minIndex = 0
        var minValue: Double? = nil
        for (index, value) in array.enumerate() where !flag[index]
        {
            if isLess(value, rhs: minValue) {
                minIndex = index
                minValue = array[index]
            }
        }
        if let value = minValue {
            return (value, minIndex)
        }
        return nil
    }
    
    private func configurePathToPoint(predecessors: [Int?], endPoint: Int) -> PathInfo? {
        if endPoint == startPoint {
            return PathInfo(path: [startPoint], distance: 0)
        }
        var distance = 0.0
        var relay = endPoint
        var reversedPath = [Int]()
        reversedPath.append(endPoint)
        while let predecessor = predecessors[relay] {
            reversedPath.append(predecessor)
            distance += graph[predecessor][relay]!
            relay = predecessor
            if predecessor == startPoint {
                break
            }
        }
        if relay != startPoint {
            return nil
        }
        return PathInfo(path: reversedPath.reverse(), distance: distance)
    }
    
    private func isLess(lhs: Double?, rhs: Double?) -> Bool {
        if lhs == nil {
            return false
        }
        if rhs == nil {
            return true
        }
        return lhs < rhs
    }
    
    init(graph: [[Double?]], startPoint: Int) {
        self.graph = graph
        self.startPoint = startPoint
        prepareForConfigure()
    }
    private mutating func prepareForConfigure()
    {
        predecessors = Array(count: graph.count, repeatedValue: nil)
        for (dest, value) in graph[startPoint].enumerate() where value != nil
        {
            predecessors[dest] = startPoint
        }
        predecessors[startPoint] = startPoint
        predecessorsHistory = [predecessors]
        
        pathsInfo = Array(count: graph.count, repeatedValue: nil)
        flag = Array(count: graph.count, repeatedValue: false)
        flag[startPoint] = true
        nodes = [startPoint]
    }
    private var didConfigure = false
}



