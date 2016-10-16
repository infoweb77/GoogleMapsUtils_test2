//
//  GCkusterAlgorithm.swift
//  GoogleMapsUtils_test
//
//  Created by alex on 04/10/16.
//  Copyright © 2016 alex. All rights reserved.
//

import Foundation

protocol GClusterAlgorithm {
    func addItems(items: [GClusterItem])
    func removeItem(item: GClusterItem)
    func clearItems()

    func clustersAtZoom(zoom: Float) -> [GCluster]
}

