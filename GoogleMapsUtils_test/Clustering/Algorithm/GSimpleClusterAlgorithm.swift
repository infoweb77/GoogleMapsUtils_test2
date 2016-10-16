//
//  GSimpleClusterAlgorithm.swift
//  GoogleMapsUtils_test
//
//  Created by alex on 12/10/16.
//  Copyright © 2016 alex. All rights reserved.
//

import Foundation

class GSimpleClusterAlgorithm: GClusterAlgorithm {
    
   let kClusterCount = 10
    
    private var _items: [GClusterItem]
    
    init() {
        _items = [GClusterItem]()
    }
    
    func addItems(items: [GClusterItem]) {
        _items.appendContentsOf(items)
    }
    
    func removeItem(item: GClusterItem) {
        if let index = _items.indexOf({ $0 == item }) {
            _items.removeAtIndex(index)
        }
    }
    
    func clearItems() {
        _items.removeAll()
    }
    
    func clustersAtZoom(zoom: Float) -> [GCluster] {
        var clusters = [GCluster]()
        
        for var i in 0..<kClusterCount {
            if i >= _items.count {
                break
            }
            let item = _items[i]
            let statCluster = GStaticCluster(position: item.position)
            clusters.append(statCluster)
        }
        
        var clusterIndex = 0
        for (var i = kClusterCount; i < _items.count; ++i) {
            let item = _items[i]
            let index = clusterIndex % kClusterCount
            let cluster = clusters[index] as! GStaticCluster
            cluster.add(item)
            ++clusterIndex
        }
        return clusters
    }
}