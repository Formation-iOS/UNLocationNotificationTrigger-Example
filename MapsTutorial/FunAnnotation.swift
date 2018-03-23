//
//  FunAnnotation.swift
//  MapsTutorial
//
//  Created by Claire Reynaud on 23/03/2018.
//  Copyright © 2018 Claire Reynaud EIRL. All rights reserved.
//

import Foundation
import MapKit

class FunAnnotation: NSObject, MKAnnotation {
    
    var mapPoint: FunMapPoint
    
    var coordinate: CLLocationCoordinate2D {
        return mapPoint.coordinate
    }
    
    var title: String? {
        return mapPoint.title
    }
    
    init(mapPoint : FunMapPoint) {
        self.mapPoint = mapPoint
    }
}
