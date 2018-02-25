//
//  DemoItems.swift
//  LocationDemo
//
//  Created by 典萱 高 on 2018/2/25.
//  Copyright © 2018年 LostRfounds. All rights reserved.
//

import Foundation

enum DemoItems: String {
    case Beacon = "iBeacon (Indoor)",
    LocationOnce = "requestLocation (once)",
    LocationUpdating = "UpdatingLocation",
    Heading = "UpdatingHeading",
    SignificantChange = "Significant-Change Location",
    None = ""
}
