//
//  MKAnnotation.swift
//  OnTheMap
//
//  Created by Erwin Santacruz on 7/26/15.
//  Copyright (c) 2015 Erwin Santacruz. All rights reserved.
//

import UIKit
import MapKit

class MapPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}