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

    var locationDetails: [RouteModel] = [RouteModel]()
    var weight: CLLocationDistance = CLLocationDistance()
    
    var startLat: CLLocationDegrees = 41.8851024
    var startLong: CLLocationDegrees = -87.6618988
    var startCoordinate: CLLocation = CLLocation()
    let startPositionName: String = "kitchen"
    let startPositionAddress: String = "Lake and Racine Ave"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startCoordinate = CLLocation(latitude: startLat, longitude: startLong)
        
        self.parseCSV {
            self.generateWeightforNodes(fromPosition: self.startCoordinate)
        }
        self.generateGraph {
            
        }

    }

    func parseCSV(completed: @escaping () -> ()) {
        
        guard let path = Bundle.main.path(forResource: "KioskCoords", ofType: "csv") else { return }

        do {
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            
            for row in 0...rows.count - 1 {
                if let name = rows[row]["name"], let address = rows[row]["address (S)"], let latitude = rows[row]["latitude (N)"], let longitude = rows[row]["longitude (N)"] {
                    let routeModelObject = RouteModel(name: name, address: address, latitude: latitude, longitude: longitude)
                    locationDetails.append(routeModelObject)
                }
            }
            
        } catch let err as NSError {
            print(err.localizedDescription)
        }
        completed()
    }
    
    func generateWeightforNodes(fromPosition position: CLLocation) {
        for i in 0...locationDetails.count - 1 {
            guard let lat: CLLocationDegrees = Double(locationDetails[i].latitude) else {return}
            guard let lon: CLLocationDegrees = Double(locationDetails[i].longitude) else {return}
            let coordinate = CLLocation(latitude: lat, longitude: lon)
            weight = position.distance(from: coordinate)
            locationDetails[i].setWeight(weight: weight)
            //print(locationDetails[i].weight)
        }

    }
    
    func generateGraph(completed: @escaping ()->()) {
        for i in 0...locationDetails.count - 2 {
            let node = Node(id: locationDetails[i].name)
            for j in i+1...locationDetails.count - 1 {
                let neighbour = Node(id: locationDetails[j].name)
                node.modelconnections.append(Neighbours(node: neighbour, weight: locationDetails[j].weight))
            }
            print(node.id)
        }
        completed()
    }
    
    func shortestPath(source: Node, destination: Node) -> Path? {
        var frontier: [Path] = [] {
            didSet {
                frontier.sort { (path1, path2) -> Bool in
                    return path1.cumulativeWeight < path2.cumulativeWeight
                }
            }
        }
        frontier.append(Path(node: source))
        while !frontier.isEmpty {
            //get the cheapest path available
            let lowestWeight = frontier.removeFirst()
            guard !lowestWeight.node.visited else { continue }
            
            if lowestWeight.node === destination {
                return lowestWeight
            }
            
            lowestWeight.node.visited = true
            for neighbour in lowestWeight.node.modelconnections where !neighbour.neighbour.visited {
                frontier.append(Path(node: neighbour.neighbour, neighbour: neighbour, previousPath: lowestWeight))
            }
            
            
        }
        return nil
    }
    
}

