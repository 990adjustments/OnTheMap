//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Erwin Santacruz on 7/25/15.
//  Copyright (c) 2015 Erwin Santacruz. All rights reserved.
//

import MapKit

struct StudentInformation {
    
    var firstName: String
    var lastName: String
    var latitude: Double
    var longitude: Double
    var mapString: String
    var mediaURL: String
    
    // Construct student information from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        mapString = dictionary["mapString"] as! String
        mediaURL = dictionary["mediaURL"] as! String
    }
    
    // Return an array of StudentInformation structs
    static func studentsFromResults(results: NSArray) -> [StudentInformation] {
        var students = [StudentInformation]()
        
        for student in results {
            var info = StudentInformation(dictionary: student as! [String : AnyObject])
            students.append(info)
        }

        return students
    }

}
