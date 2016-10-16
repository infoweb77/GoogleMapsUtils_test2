//
//  NonHierarchicalDistanceBasedAlgorithm.swift
//  GoogleMapsUtils_test
//
//  Created by alex on 04/10/16.
//  Copyright © 2016 alex. All rights reserved.
//

import Foundation
import GoogleMaps

let kGClusterDistancePoints = 100
let kGMapPointWidth = 2.0 // MapPoint is in a [-1,1]x[-1,1] space.

class NonHierarchicalDistanceBasedAlgorithm: NSObject, GClusterAlgorithm {
    
    private var _items: [GClusterItem]
    private var _quadTree: GQTPointQuadTree
    
    override init() {
        _items = [GClusterItem]()
        let bounds = GQTBounds(minX: -1.0, minY: -1.0, maxX: 1.0, maxY: 1.0)
        _quadTree = GQTPointQuadTree(bounds: bounds)
    }
    
    func addItems(items: [GClusterItem]) {
        _items.appendContentsOf(items)
        for item in items {
            let quadItem = GClusterItemQuadItem(clusterItem: item)
            _quadTree.add(quadItem)
        }
    }
    
    func removeItem(item: GClusterItem) {
        if let index = _items.indexOf({ $0 == item }) {
            _items.removeAtIndex(index)
        }
        let quadItem = GClusterItemQuadItem(clusterItem: item)
        _quadTree.remove(quadItem)
    }
    
    func clearItems() {
        _items.removeAll()
        _quadTree.clear()
    }
    
    func clustersAtZoom(zoom: Float) -> [GCluster] {
        var clusters = [GCluster]()
        var itemToClusterMap = [GWrappingDictionaryKey: GCluster]()
        var itemToClusterDistanceMap = [GWrappingDictionaryKey: Double]()
        let processedItems = NSMutableSet()
        
        for item in _items {
            if processedItems.containsObject(item) {
                continue
            }
            
            let cluster = GStaticCluster(position: item.position)
            let point = GMSProject(item.position)
            
            let radius = Double(kGClusterDistancePoints) * kGMapPointWidth / pow(2.0, Double(zoom) + 8.0)
            let bounds = GQTBounds(minX: point.x - radius, minY: point.y - radius, maxX: point.x + radius, maxY: point.y + radius)
            let nearbyItems = _quadTree.search(bounds)
            
            for qItem in nearbyItems {
                let quadItem = qItem as! GClusterItemQuadItem
                let nearbyItem = quadItem.clusterItem
                processedItems.addObject(nearbyItem)
                
                let nearbyItemPoint = GMSProject(nearbyItem.position)
                let key = GWrappingDictionaryKey(object: nearbyItem)
                
                let existingDistance = itemToClusterDistanceMap[key]
                let qtpoint = GQTPoint(x: point.x, y: point.y)
                let qtNearby = GQTPoint(x: nearbyItemPoint.x, y: nearbyItemPoint.y)
                let distanceSquared = self.distanceSquared(qtpoint, b: qtNearby)
                
                if existingDistance != nil {
                    if existingDistance! < distanceSquared {
                        continue
                    }
                    let existingCluster = itemToClusterMap[key] as! GStaticCluster
                    existingCluster.remove(nearbyItem)
                }
                
                itemToClusterDistanceMap.updateValue(distanceSquared, forKey: key)
                itemToClusterMap.updateValue(cluster, forKey: key)
                
                cluster.add(nearbyItem)
            }
            clusters.append(cluster)
        }
        return clusters
    }
    
    private func distanceSquared(a: GQTPoint, b: GQTPoint) -> Double {
        return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)
    }
    
}
