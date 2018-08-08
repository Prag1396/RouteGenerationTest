//
//  Graph.swift
//  RouteGeneration
//
//  Created by Pragun Sharma on 8/7/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import Foundation

class Node {
    private var _id: String!
    
    var id: String {
        if _id == nil {
            _id = ""
        }
        return _id
    }
    
    init(id: String) {
        self._id = id
    }
    
    var visited = false
    var modelconnections: [Neighbours] = [Neighbours]()
}

class Neighbours {
    public let neighbour: Node
    public let weight: Double
    
    public init(node: Node, weight: Double) {
        self.neighbour = node
        self.weight = weight
    }
}

class Path {
    public let cumulativeWeight: Double
    public let node: Node
    public let previousPath: Path?
    
    init(node: Node, neighbour: Neighbours? = nil, previousPath path: Path? = nil) {
        if let previousPath = path, let neighbour = neighbour {
            self.cumulativeWeight = neighbour.weight + previousPath.cumulativeWeight
        } else {
            self.cumulativeWeight = 0
        }
        self.node = node
        self.previousPath = path
    }
}
