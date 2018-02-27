//
//  FirebaseReference.swift
//  LocationDemo
//
//  Created by 典萱 高 on 2018/2/25.
//  Copyright © 2018年 LostRfounds. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

struct FirebaseRef {
    static let databaseRoot: DatabaseReference = Database.database().reference()
    static let databaseSignificantChange: DatabaseReference = databaseRoot.child("significant_change")
    static let databaseVisits: DatabaseReference = databaseRoot.child("visits")
    static let databaseUpdatingLocations: DatabaseReference = databaseRoot.child("update_locations")
    static let databaseHeading: DatabaseReference = databaseRoot.child("headings")

    static func saveHeadingInfoWith(
        newHeading: CLHeading,
        databaseRef reference: DatabaseReference,
        dateFormatter: DateFormatter
    ) {
        let dateString = dateFormatter.string(from: newHeading.timestamp)
        let key = dateString
        let timestamp = newHeading.timestamp.timeIntervalSince1970

        let recordReference = reference.child(key)
        let object: [String: Any] = [
            "headings": [
                "magneticHeading": newHeading.magneticHeading,
                "trueHeading": newHeading.trueHeading,
                "accuracy": newHeading.headingAccuracy
            ],
            "timestamp": Int(timestamp),
            "x": newHeading.x,
            "y": newHeading.y,
            "z": newHeading.z
        ]
        recordReference.setValue(object)

    }

    static func saveLocationInfoWith(
        location: CLLocation,
        databaseRef reference: DatabaseReference,
        dateFormatter: DateFormatter
    ) {
        let dateString = dateFormatter.string(from: location.timestamp)
        let key = dateString
        let timestamp = location.timestamp.timeIntervalSince1970
        var level = "N/A"
        if let floor = location.floor {
            level = "\(floor.level)"
        }

        let recordReference = reference.child(key)
        let object: [String: Any] = [
            "coordinate": [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ],
            "altitude": location.altitude,
            "floor": level,
            "timestamp": Int(timestamp),
            "speed": location.speed,
            "course": location.course
        ]
        recordReference.setValue(object)
    }
}
