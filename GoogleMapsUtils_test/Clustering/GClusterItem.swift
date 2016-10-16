//
//  GClusterItem.swift
//  GoogleMapsUtils_test
//
//  Created by alex on 03/10/16.
//  Copyright © 2016 alex. All rights reserved.
//

import Foundation
import CoreLocation

protocol GClusterItem: NSObjectProtocol {
    var position: CLLocationCoordinate2D { get }
}

func == (lhs: GClusterItem,rhs: GClusterItem) -> Bool {
    return lhs.position.latitude == rhs.position.latitude && lhs.position.longitude == rhs.position.longitude
}
