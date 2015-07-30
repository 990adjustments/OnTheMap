//
//  Students.swift
//  OnTheMap
//
//  Created by Erwin Santacruz on 7/25/15.
//  Copyright (c) 2015 Erwin Santacruz. All rights reserved.
//

import MapKit

class Students {
    let students: [StudentInformation]?
    
    init(students: [StudentInformation])
    {
        self.students = students
    }
    
    func getMKAnnotation() -> [MKAnnotation]
    {
        var annotations = [MKAnnotation]()
        for student in students! {
            var annotation = MapPin(coordinate: getCoordinate(student), title: "\(student.firstName) \(student.lastName)", subtitle: student.mediaURL)
            annotations.append(annotation)
        }
        
        return annotations
    }
    
    func getCoordinate(student: StudentInformation) -> CLLocationCoordinate2D
    {
        return CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
    }
}