//
//  GWrappingDictionaryKey.swift
//  GoogleMapsUtils_test
//
//  Created by alex on 13/10/16.
//  Copyright © 2016 alex. All rights reserved.
//

import Foundation

class GWrappingDictionaryKey: NSObject, NSCopying {
    
    private var _object: AnyObject
    
    override var hash: Int {
        return _object.hash
    }
    
    init(object: AnyObject) {
        _object = object
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let newKey = GWrappingDictionaryKey(object: _object)
        return newKey
    }

    
    override func isEqual(other: AnyObject?) -> Bool {
        if self === other {
            return true
        }
        
        guard let other = other as? GWrappingDictionaryKey else {
            return false
        }
        
        return self._object.isEqual(other._object)
    }
}
