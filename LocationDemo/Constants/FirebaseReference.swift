//
//  FirebaseReference.swift
//  LocationDemo
//
//  Created by 典萱 高 on 2018/2/25.
//  Copyright © 2018年 LostRfounds. All rights reserved.
//

import Foundation
import Firebase

struct FirebaseRef {
    static let databaseRoot: DatabaseReference = Database.database().reference()
    static let databaseSignificantChange: DatabaseReference = databaseRoot.child("significant_change")
    static let databaseVisits: DatabaseReference = databaseRoot.child("visits")
    static let databaseUpdatingLocations: DatabaseReference = databaseRoot.child("update_locations")

}
