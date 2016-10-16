//
//  GClusterItemQuadItem.swift
//  GoogleMapsUtils_test
//
//  Created by alex on 12/10/16.
//  Copyright © 2016 alex. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps

class GClusterItemQuadItem: NSObject, GQTPointQuadTreeItem {
    
    private var _clusterItem: GClusterItem
    private var _clusterItemPoint: GQTPoint
    
    var point: GQTPoint {
        return _clusterItemPoint
    }
    
    var clusterItem: GClusterItem {
        return _clusterItem
    }
    
    init(clusterItem: GClusterItem) {
        _clusterItem = clusterItem
        let point = GMSProject(clusterItem.position)
        _clusterItemPoint = GQTPoint(x: point.x, y: point.y)
    }
    
    override func isEqual(other: AnyObject?) -> Bool {
        if self === other {
            return true
        }
        
        guard let other = other as? GClusterItemQuadItem else {
            return false
        }
        
        return self._clusterItem.isEqual(other._clusterItem)
    }

    
    override var hash: Int {
        return _clusterItem.hash
    }
}


