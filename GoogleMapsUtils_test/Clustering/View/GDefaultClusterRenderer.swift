//
//  GDefaultClusterRenderer.swift
//  GoogleMapsUtils_test
//
//  Created by alex on 04/10/16.
//  Copyright © 2016 alex. All rights reserved.
//

import Foundation
import GoogleMaps

let kMinClusterSize = 4
let kMaxClusterZoom = 20.0
let kAnimationDuration = 0.5

class GDefaultClusterRenderer: GClusterRenderer {
    
    private var _mapView: GMSMapView
    
    private var _markers: [GMSMarker]
    private var _clusters: [GCluster]
    
    private var _renderedClusters: NSMutableSet
    private var _renderedClusterItems: NSMutableSet
    
    private var _itemToOldClusterMap = [GWrappingDictionaryKey: GCluster]()
    private var _itemToNewClusterMap = [GWrappingDictionaryKey: GCluster]()
    
    private var _previousZoom: Float?
    
    var animatesClusters: Bool
    var zIndex: Int
    
    private var _iconCache = NSCache()
    private let _buckets = [ 10, 25, 50, 100, 250, 500, 1000 ]
    
    init(mapView: GMSMapView) {
        _mapView = mapView
        
        _markers = [GMSMarker]()
        _clusters = [GCluster]()
        
        _renderedClusters = NSMutableSet()
        _renderedClusterItems = NSMutableSet()
        
        animatesClusters = true
        zIndex = 1
    }
    
    private func shouldRenderAsCluster(cluster: GCluster, atZoom zoom: Float) -> Bool {
        return cluster.count >= kMinClusterSize && Double(zoom) <= kMaxClusterZoom
    }
    
    func renderClusters(clusters: [GCluster]) {
        _renderedClusters.removeAllObjects()
        _renderedClusterItems.removeAllObjects()
        
        if animatesClusters {
            self.renderAnimatedClusters(clusters)
        }
        else {
            _clusters = clusters
            clearMarkers(_markers)
            _markers = [GMSMarker]()
            addOrUpdateClusters(clusters, animated: false)
        }
    }
    
    private func renderAnimatedClusters(clusters: [GCluster]) {
        let zoom = _mapView.camera.zoom
        let isZoomingIn = zoom > _previousZoom
        _previousZoom = zoom
        
        prepareClustersForAnimation(clusters, isZoomingIn: isZoomingIn)
        
        _clusters = clusters
        
        let existingMarkers = _markers
        _markers = [GMSMarker]()
        
        addOrUpdateClusters(clusters, animated: isZoomingIn)
        if isZoomingIn {
            clearMarkers(existingMarkers)
        }
        else {
            clearMarkersAnimated(existingMarkers)
        }
    }
    
    private func clearMarkersAnimated(markers: [GMSMarker]) {
        let visibleRegion = _mapView.projection.visibleRegion()
        let visibleBounds = GMSCoordinateBounds.init(region: visibleRegion)
        
        for marker in markers {
            // If the marker for the attached userData has just been added, do not perform animation.
            if _renderedClusterItems.containsObject(marker.userData!) {
                marker.map = nil
                continue
            }
            // If the marker is outside the visible view port, do not perform animation.
            if !visibleBounds.containsCoordinate(marker.position) {
                marker.map = nil
                continue
            }
            
            // Find a candidate cluster to animate to.
            var toCluster: GCluster?
            if marker.userData is GCluster {
                let cluster = marker.userData as! GCluster
                toCluster = self.overlappingClusterForCluster(cluster, itemMap: _itemToNewClusterMap)
            }
            else {
                let key = GWrappingDictionaryKey(object: marker.userData!)
                toCluster = _itemToNewClusterMap[key]
            }
            
            // If there is not near by cluster to animate to, do not perform animation.
            if toCluster == nil {
                marker.map = nil
                continue
            }
            
            CATransaction.begin()
            CATransaction.setValue(kAnimationDuration, forKey: kCATransactionAnimationDuration)
            let toPosition = toCluster?.position
            marker.layer.latitude = (toPosition?.latitude)!
            marker.layer.longitude = (toPosition?.longitude)!
            CATransaction.commit()
            
            // Clears existing markers after animation has presumably ended.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(kAnimationDuration) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
                self.clearMarkers(markers)
            }
        }
    }
    
    func update() {
        addOrUpdateClusters(_clusters, animated: false)
    }
    
    private func prepareClustersForAnimation(newClusters: [GCluster], isZoomingIn isZoomIn :Bool) {
        let zoom = _mapView.camera.zoom
        
        if isZoomIn {
            _itemToOldClusterMap = [GWrappingDictionaryKey: GCluster]()
            for cluster in _clusters {
                if !shouldRenderAsCluster(cluster, atZoom: zoom) {
                    continue
                }
                for clusterItem in cluster.items {
                    let key = GWrappingDictionaryKey(object: clusterItem)
                    _itemToOldClusterMap.updateValue(cluster, forKey: key)
                }
                _itemToNewClusterMap.removeAll()
            }
        }
        else {
            _itemToOldClusterMap.removeAll()
            _itemToNewClusterMap = [GWrappingDictionaryKey: GCluster]()
            for cluster in newClusters {
                if !shouldRenderAsCluster(cluster, atZoom: zoom) {
                    continue
                }
                for clusterItem in cluster.items {
                    let key = GWrappingDictionaryKey(object: clusterItem)
                    _itemToNewClusterMap.updateValue(cluster, forKey: key)
                }
                
            }
        }
    }
    
    private func addOrUpdateClusters(clusters: [GCluster], animated anim: Bool) {
        let region = _mapView.projection.visibleRegion()
        let visibleBounds = GMSCoordinateBounds(region: region)
        
        for cluster in clusters {
            if _renderedClusters.containsObject(cluster as! AnyObject) {
                continue
            }
            
            var shouldShowCluster = visibleBounds.containsCoordinate(cluster.position)
            if !shouldShowCluster && anim {
                for item in cluster.items {
                    let key = GWrappingDictionaryKey(object: item)
                    let oldCluster = _itemToOldClusterMap[key]
                    if oldCluster != nil && visibleBounds.containsCoordinate((oldCluster?.position)!) {
                        shouldShowCluster = true
                        break
                    }
                }
            }
            
            if shouldShowCluster {
                self.renderCluster(cluster, animated: anim)
            }
        }
    }
    
    private func renderCluster(cluster: GCluster, animated anim: Bool) {
        let zoom = _mapView.camera.zoom
        
        var fromPosition = kCLLocationCoordinate2DInvalid
        var animated = anim
        
        if shouldRenderAsCluster(cluster, atZoom: zoom) {
            if anim {
                let fromCluster = overlappingClusterForCluster(cluster, itemMap: _itemToOldClusterMap)
                if fromCluster != nil {
                    animated = true
                    fromPosition = fromCluster!.position
                }
            }
            
            let marker = self.markerWithPosition(cluster.position, from: fromPosition, userData: cluster as! AnyObject, clusterCount: cluster.count, animated: animated)
            
            _markers.append(marker)
        }
        else {
            for item in cluster.items {
                fromPosition = kCLLocationCoordinate2DInvalid
                if anim {
                    let key = GWrappingDictionaryKey(object: item)
                    let fromCluster = _itemToOldClusterMap[key]
                    if fromCluster != nil {
                        animated = true
                        fromPosition = fromCluster!.position
                    }
                }
                
                let marker = self.markerWithPosition(cluster.position, from: fromPosition, userData: cluster as! AnyObject, clusterCount: 1, animated: animated)
                
                _markers.append(marker)
                _renderedClusterItems.addObject(item)
            }
        }
        _renderedClusters.addObject(cluster as! AnyObject)
    }
    
    private func markerWithPosition(position: CLLocationCoordinate2D, from frm: CLLocationCoordinate2D, userData usrData: AnyObject, clusterCount count: Int, animated anim: Bool) -> GMSMarker {
        
        let initialPosition = anim ? frm : position
        
        let marker = GMSMarker()
        marker.position = initialPosition
        marker.userData = usrData
        
        let bucketIndex = self.bucketIndexForSize(count)
        var text: String
        
        if count < _buckets[0] {
            text = "\(count)"
        }
        else {
            text = "\(_buckets[bucketIndex])+"
        }
        
        if count > 1 {
            let iconView: UIView
            let icon = _iconCache.objectForKey(text)
            if icon != nil {
                iconView = icon as! UIView
            }
            else {
                iconView = GDefaultClusterMarkerIconView(count: count)
                _iconCache.setObject(iconView, forKey: text)
            }
        
            marker.iconView = iconView
            marker.userData = count
        }

        marker.zIndex = Int32(zIndex)
        marker.map = _mapView
        
        if anim {
            CATransaction.begin()
            CATransaction.setValue(kAnimationDuration, forKey: kCATransactionAnimationDuration)
            marker.layer.latitude = position.latitude
            marker.layer.longitude = position.longitude
            CATransaction.commit()
        }
        
        return marker
    }
    
    private func bucketIndexForSize(size: Int) -> Int {
        var index = 0
        while index + 1 < _buckets.count && _buckets[index + 1] <= size {
            ++index
        }
        return index
    }
    
    private func visibleClustersFromClusters(clusters: [GCluster]) -> [GCluster] {
        var visibleClusters = [GCluster]()
        
        let zoom = _mapView.camera.zoom
        let visibleBounds = GMSCoordinateBounds.init(region: _mapView.projection.visibleRegion())
        
        for cluster in clusters {
            if !visibleBounds.containsCoordinate(cluster.position) {
                continue
            }
            if !self.shouldRenderAsCluster(cluster, atZoom: zoom) {
                continue
            }
            visibleClusters.append(cluster)
        }
        
        return visibleClusters
    }
    
    // Returns the first cluster in |itemMap| that shares a common item with the input |cluster|.
    // Used for heuristically finding candidate cluster to animate to/from.
    private func overlappingClusterForCluster(cluster: GCluster, itemMap mapItem: [GWrappingDictionaryKey: GCluster]) -> GCluster? {
        var found: GCluster?
        
        for item in cluster.items {
            let key = GWrappingDictionaryKey(object: item)
            let candidate = mapItem[key]
            if candidate != nil {
                found = candidate
                break
            }
        }
        
        return found
    }
    
    private func clear() {
        self.clearMarkers(_markers)
        _markers.removeAll()
        
        _renderedClusters.removeAllObjects()
        _renderedClusterItems.removeAllObjects()
        
        _itemToNewClusterMap.removeAll()
        _itemToOldClusterMap.removeAll()
        
        _clusters = []
    }
    
    private func clearMarkers(markers: [GMSMarker]) {
        for marker in markers {
            marker.userData = nil
            marker.map = nil
        }
    }
    
}













