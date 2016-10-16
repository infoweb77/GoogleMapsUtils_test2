//
//  GStaticCluster.swift
//  GoogleMapsUtils_test
//
//  Created by alex on 04/10/16.
//  Copyright © 2016 alex. All rights reserved.
//

import Foundation
import CoreLocation
//import GoogleMaps

class GStaticCluster: GCluster {
    
    private var _position: CLLocationCoordinate2D
    private var _count: Int
    private var _items: [GClusterItem]
    
    var items: [GClusterItem] {
        let duplicate = _items
        return duplicate
    }
    
    var count: Int {
        return _items.count
    }
    
    var position: CLLocationCoordinate2D {
        return _position
    }
    
    init(position: CLLocationCoordinate2D) {
        _position = position
        _items = [GClusterItem]()
        _count = 0
    }
    
    func add(item: GClusterItem) {
        _items.append(item)
    }
    
    func remove(item: GClusterItem) {
        if let index = _items.indexOf({ $0 == item }) {
            _items.removeAtIndex(index)
        }
    }
}

