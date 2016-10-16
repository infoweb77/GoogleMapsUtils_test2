//
//  GClusterManager.swift
//  GoogleMapsUtils_test
//
//  Created by alex on 04/10/16.
//  Copyright © 2016 alex. All rights reserved.
//

import GoogleMaps
import UIKit

protocol GClusterManagerDelegate {
    func clusterManager(clusterManager: GClusterManager, didTapCluster cluster: GCluster)
    //func clusterManager(clusterManager: GClusterManager, didTapClusterItem clusterItem: GClusterItem)
}

final class GClusterManager: NSObject {
    
    private var _mapView:GMSMapView
    private var _previousCamera: GMSCameraPosition
    private var _renderer: GClusterRenderer
    
    var _algorithm: GClusterAlgorithm
    
    var delegate: GClusterManagerDelegate?
    weak var mapDelegate: GMSMapViewDelegate?
    
    var start = true
    
    var items: NSMutableArray?
    
    init(mapView: GMSMapView, algorithm: GClusterAlgorithm, renderer: GClusterRenderer) {
        _mapView = mapView
        _previousCamera = mapView.camera
        _algorithm = algorithm
        _renderer = renderer
        
        super.init()
    }
    
    func addItem(item: GClusterItem) {
        let itArr = [item]
        _algorithm.addItems(itArr)
    }
    
    func addItems(items: [GClusterItem]) {
        _algorithm.addItems(items)
    }
    
    func removeItem(item: GClusterItem) {
        _algorithm.removeItem(item)
    }
    
    func clearItems() {
        _algorithm.clearItems()
        self.cluster()
    }
    
    func cluster() {
        let integralZoom = floorf(_mapView.camera.zoom + 0.5)
        let clusters = _algorithm.clustersAtZoom(integralZoom)
        _renderer.renderClusters(clusters)
            
        _previousCamera = _mapView.camera
    }
    
    func setDelegate(delegate: GClusterManagerDelegate, mapDelegate mapDel: GMSMapViewDelegate) {
        self.delegate = delegate
        _mapView.delegate = self
        self.mapDelegate = mapDel
    }
}

extension GClusterManager: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView, willMove gesture: Bool) {
        mapDelegate?.mapView?(mapView, willMove: gesture)
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        mapDelegate?.mapView?(mapView, didChangeCameraPosition: position)
    }
    
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        self.cluster()
        
        mapDelegate?.mapView?(mapView, idleAtCameraPosition: position)
    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        mapDelegate?.mapView?(mapView, didTapAtCoordinate: coordinate)
    }
    
    func mapView(mapView: GMSMapView, didCloseInfoWindowOfMarker marker: GMSMarker) {
        mapDelegate?.mapView?(mapView, didCloseInfoWindowOfMarker: marker)
    }
    
    func mapView(mapView: GMSMapView, didBeginDraggingMarker marker: GMSMarker) {
        mapDelegate?.mapView?(mapView, didBeginDraggingMarker: marker)
    }
    
    func mapView(mapView: GMSMapView, didLongPressInfoWindowOfMarker marker: GMSMarker) {
        mapDelegate?.mapView?(mapView, didLongPressInfoWindowOfMarker: marker)
    }
    
    func mapView(mapView: GMSMapView, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        mapDelegate?.mapView?(mapView, didLongPressAtCoordinate: coordinate)
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        if let result = mapDelegate?.mapView?(mapView, didTapMarker: marker) {
            return result
        }
        
        return false
    }
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        mapDelegate?.mapView?(mapView, didTapInfoWindowOfMarker: marker)
    }
    
    func mapView(mapView: GMSMapView, didTapOverlay overlay: GMSOverlay) {
        mapDelegate?.mapView?(mapView, didTapOverlay: overlay)
    }
    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if let view = mapDelegate?.mapView?(mapView, markerInfoWindow: marker) {
            return view
        }
        
        return nil
    }
    
    func mapView(mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        if let view = mapDelegate?.mapView?(mapView, markerInfoContents: marker) {
            return view
        }
        
        return nil
    }
    
    func mapView(mapView: GMSMapView, didEndDraggingMarker marker: GMSMarker) {
        mapDelegate?.mapView?(mapView, didEndDraggingMarker: marker)
    }
    
    func mapView(mapView: GMSMapView, didDragMarker marker: GMSMarker) {
        mapDelegate?.mapView?(mapView, didDragMarker: marker)
    }
}


