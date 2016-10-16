//
//  GCluster.swift
//  GoogleMapsUtils_test
//
//  Created by alex on 03/10/16.
//  Copyright © 2016 alex. All rights reserved.
//

import Foundation
import CoreLocation

protocol GCluster {
    var position: CLLocationCoordinate2D { get }
    var items: [GClusterItem] { get }
    var count: Int { get }
}

