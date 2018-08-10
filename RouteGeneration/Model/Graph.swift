//
//  Graph.swift
//  RouteGeneration
//
//  Created by Pragun Sharma on 8/7/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import Foundation

//Node Class BluePrint
class Node: Hashable {
    
    var hashValue: Int
    
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    private var _name: String!
    private var _address: String!
    private var _latitude: String!
    private var _longitude: String!

    
    var name: String {
        return _name
    }
    
    var address: String {
        return _address
    }
    
    var latitude: String {
        return _latitude
    }
    
    var longitude: String {
        return _longitude
    }
    
    init(name: String, address: String, latitude: String, longitude: String) {
        self._name = name
        self._address = address
        self._latitude = latitude
        self._longitude = longitude
        if let val1 = Double(latitude), let val2 = Double(longitude) {
            self.hashValue = Int(val1 * val2 * 10000)
        } else {
            self.hashValue = -1
        }
    }
    
    var visited = false
    var modelconnections: [Neighbours] = [Neighbours]()
}

//Edge Class Blueprint
class Neighbours {
    public let neighbour: Node
    private var _weight: Double!

    var weight: Double {
        get {
           return _weight
        } set {
            self._weight = newValue
        }
    }
    
    public init(node: Node, weight: Double? = nil) {
        self.neighbour = node
        self._weight = weight
    }
}
