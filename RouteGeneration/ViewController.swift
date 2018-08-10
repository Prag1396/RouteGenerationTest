//
//  ViewController.swift
//  RouteGeneration
//
//  Created by Pragun Sharma on 8/7/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    var nodeArray: [Node] = [Node]()
    var nodeArrayAboveAverage: [Node] = [Node]()
    var nodeArrayBelowAverage: [Node] = [Node]()
    var weight: CLLocationDistance = CLLocationDistance()
    var distanceWeightMatrix: [Two<Node, Node>: Double] = [:]
    
    var startLat: CLLocationDegrees = 41.8851024
    var startLong: CLLocationDegrees = -87.6618988
    var startCoordinate: CLLocation = CLLocation()
    let startPositionName: String = "kitchen"
    let startPositionAddress: String = "Lake and Racine Ave"
    var startNode: Node!
    var path1: [Node] = [Node]()
    var path2: [Node] = [Node]()
    var averageWeight: Double = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.parseCSV {
            self.generateWeightNodeToConnections {
                
                self.startNode = self.nodeArray[0]
                print("Start Node \(self.startNode.name, self.startNode.address)")
                for i in 0...self.nodeArray.count - 1 {
                    for j in 0...self.nodeArray[i].modelconnections.count - 1 {
                        self.distanceWeightMatrix[Two(values: (self.nodeArray[i], self.nodeArray[i].modelconnections[j].neighbour))] = self.nodeArray[i].modelconnections[j].weight
                    }
                }
                
                //Divide locations in two Arrays according to weight
                self.divideEnteries {
                    
                    self.path1 = self.shortestPath(arrayToSearch: self.nodeArrayBelowAverage)
                    self.path2 = self.shortestPath(arrayToSearch: self.nodeArrayAboveAverage)

                }
            }
        }
        
        print("PATH - 1")
        for val in path1 {
            print(val.name)
        }
        
        print("-----------------------------------------------------------------------")

        print("PATH - 2")
        for val in path2 {
            print(val.name)
        }
        
    }
    
    
    //Divides enteries so that we can make 2 disjoint paths
    func divideEnteries(onComplete: @escaping() -> ()) {
        
        var sum: Double = 0
        
        for i in 1...nodeArray.count - 1 {
            for j in 0...nodeArray[i].modelconnections.count - 1 {
                sum = sum + nodeArray[i].modelconnections[j].weight
            }
        }
        
        averageWeight = sum / (Double(nodeArray.count) * 49)
        
        var local_sum: Double = 0
        
        for i in 0...nodeArray.count - 1 {
            for j in 0...nodeArray[i].modelconnections.count - 1 {
                local_sum = local_sum + nodeArray[i].modelconnections[j].weight
            }
            local_sum = local_sum / 50
            if local_sum <= (averageWeight * (averageWeight + 1))/averageWeight * 0.7  { //Would not hardcode values but look at the data and figure a formula out that calculates diversions from current node's latitude and longitude
                self.nodeArrayBelowAverage.append(nodeArray[i])
            } else {
                self.nodeArrayAboveAverage.append(nodeArray[i])
            }
        }
        onComplete()
    }

    //Parses CSV FILE and makes Node objects with edges
    func parseCSV(completed: @escaping () -> ()) {
        
        guard let path = Bundle.main.path(forResource: "KioskCoords", ofType: "csv") else { return }

        do {
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            
            for row in 0...rows.count - 1 {
                if let name = rows[row]["name"], let address = rows[row]["address (S)"], let latitude = rows[row]["latitude (N)"], let longitude = rows[row]["longitude (N)"] {
                    let nodeModelObject = Node(name: name, address: address, latitude: latitude, longitude: longitude)
                    nodeArray.append(nodeModelObject)
                    for j in 0...rows.count - 1 where j != row {
                        if let _name = rows[j]["name"], let _address = rows[j]["address (S)"], let _latitude = rows[j]["latitude (N)"], let _longitude = rows[j]["longitude (N)"] {
                            let neighbour = Node(name: _name, address: _address, latitude: _latitude, longitude: _longitude)
                        nodeModelObject.modelconnections.append(Neighbours(node: neighbour))
                        }
                    }
                }
            }
            
        } catch let err as NSError {
            print(err.localizedDescription)
        }
        completed()
    }
    
    //Calculates weight of each edge
    func generateWeightNodeToConnections(completed: @escaping()->()) {
        for node in 0...nodeArray.count - 1 {
            guard let sourcelat: CLLocationDegrees = Double(nodeArray[node].latitude) else {return}
            guard let sourcelon: CLLocationDegrees = Double(nodeArray[node].longitude) else {return}
            let sourceCoord = CLLocation(latitude: sourcelat, longitude: sourcelon)
            for connection in 0...nodeArray[node].modelconnections.count - 1 {
                guard let destlat: CLLocationDegrees = Double(nodeArray[node].modelconnections[connection].neighbour.latitude) else {return}
                guard let destlon: CLLocationDegrees = Double(nodeArray[node].modelconnections[connection].neighbour.longitude) else {return}
                let destCoord = CLLocation(latitude: destlat, longitude: destlon)
                weight = sourceCoord.distance(from: destCoord)
                nodeArray[node].modelconnections[connection].weight = weight
            }
        }
        completed()
    }
    
    //Returns shortest path
    func shortestPath(arrayToSearch: [Node]) -> [Node] {
        
        var localPath: [Node] = [Node]()
        var counter = 0
        var currNodeA: Node = startNode
        while counter != arrayToSearch.count - 1 {
            currNodeA.visited = true
            let minNode = findMinimumWeight(currNode: currNodeA, arrayToSearch: arrayToSearch)
            if let minnode = minNode {
                localPath.append(minnode)
                currNodeA = minnode
            }
            counter = counter + 1
            
        }
        
        return localPath
    }
    
    //Finds edge with minimum weight
    func findMinimumWeight(currNode: Node, arrayToSearch: [Node]) -> Node? {
        var minNode: Node!
        var minVal: Double = Double.infinity
        for node in arrayToSearch {
            if let key = distanceWeightMatrix[Two(values: (currNode, node))] {
                if key < minVal && node != currNode && !node.visited {
                    minVal = distanceWeightMatrix[Two(values: (currNode, node))]!
                    minNode = node
                }
            }
        }
        return minNode
    }
    
}

//Hashable struct for nodes
struct Two<T:Hashable,U:Hashable> : Hashable {
    
    let values : (T, U)

    var hashValue : Int {
        get {
            let (a,b) = values
            return a.hashValue &* 31 &+ b.hashValue
        }
    }

    static func == (lhs: Two<T, U>, rhs: Two<T, U>) -> Bool {
        return lhs.values.0 == rhs.values.0 && rhs.values.1 == lhs.values.1
    }
}

