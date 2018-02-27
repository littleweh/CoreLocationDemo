//
//  LocationsDataProviders.swift
//  LocationDemo
//
//  Created by 典萱 高 on 2018/2/26.
//  Copyright © 2018年 LostRfounds. All rights reserved.
//

import Foundation
import CoreLocation

typealias Object = [String: Any]

protocol LocationsProviderDelegate: class {
    func locationsProvider(_ locationsProvider: LocationsProvider, didGet locations: [CLLocation])
}

class LocationsProvider {
    weak var delegate: LocationsProviderDelegate?

    func getSignificantChangeLocations() {
        FirebaseRef.databaseSignificantChange.observe(.value) { (snapshot) in
            guard
                let rootObject = snapshot.value as? Object
            else {
                print("not rootObject")
                return
            }
            var locations = [CLLocation]()

            for (_, value) in rootObject {
                guard
                    let locationObject = value as? Object
                else {
                    print("locationObject return")
                    break
                }
                guard
                    let coordinateObject = locationObject["coordinate"] as? Object,
                    let altitude = locationObject["altitude"] as? CLLocationDistance,
                    let timestamp = locationObject["timestamp"] as? TimeInterval
                else {
                    print("coordinateObject return ")
                    break
                }
                guard
                    let latitude = coordinateObject["latitude"] as? CLLocationDegrees,
                    let longitude = coordinateObject["longitude"] as? CLLocationDegrees
                else {
                    print("lat/long return")
                    break
                }
                let coordinate = CLLocationCoordinate2D(
                    latitude: latitude,
                    longitude: longitude
                )
                let date = Date(timeIntervalSince1970: timestamp)
                let location = CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: date)
                locations.append(location)
                locations = locations.sorted(by: { (location1, location2) -> Bool in
                    if location1.timestamp <= location2.timestamp {
                        return true
                    } else { return false }
                })
            }
            self.delegate?.locationsProvider(self, didGet: locations)
        }
    }

}
