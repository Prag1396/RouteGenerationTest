//
//  RouteModel.swift
//  RouteGeneration
//
//  Created by Pragun Sharma on 8/7/18.
//  Copyright © 2018 Pragun Sharma. All rights reserved.
//

import Foundation
import CoreLocation

class RouteModel {
    
    private var _name: String!
    private var _address: String!
    private var _latitude: String!
    private var _longitude: String!
    private var _weight: Double!
    
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
    
    var weight: Double {
        if _weight == nil {
            _weight = -1.0
        }
        return _weight
    }
    
    init(name: String, address: String, latitude: String, longitude: String) {
        self._name = name
        self._address = address
        self._latitude = latitude
        self._longitude = longitude
    }
    
    func setWeight(weight: Double) {
        self._weight = weight
    }

}
