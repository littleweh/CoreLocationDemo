//
//  BeaconViewController.swift
//  LocationDemo
//
//  Created by 典萱 高 on 2018/2/24.
//  Copyright © 2018年 LostRfounds. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconViewController: UIViewController {

    let backButton = UIButton()
    let proximityLabel = UILabel()
    let beaconUUID: String = "A83CA210-A397-466B-B694-5181EE035A2C"
    let beaconLocationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(backButton)
        self.view.addSubview(proximityLabel)
        setupBackButton()
        setupProximityLabel()

        beaconLocationManager.delegate = self

        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
                beaconLocationManager.requestWhenInUseAuthorization()
            }

            if let uuid = UUID(uuidString: beaconUUID) as? UUID {
                monitorBeaconRegion(with: uuid)
//                rangingBeacons(with: uuid)
            } else {
                proximityLabel.text = NSLocalizedString(
                    "Please setup an iBeacon with UUID: \(beaconUUID)",
                    comment: "proximity Label in BeaconVC"
                )
            }
        }
    }

    deinit {
        print("BeaconVC is dead")
    }

    // MARK: Beacon region monitoring, ranging

    func monitorBeaconRegion(with uuid: UUID) {
        let beaconRegion = CLBeaconRegion(
            proximityUUID: uuid,
            identifier: ""
        )

        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true

        beaconLocationManager.startMonitoring(for: beaconRegion)
    }

    func rangingBeacons(with uuid: UUID) {
        let beaconRegion = CLBeaconRegion(
            proximityUUID: uuid,
            identifier: ""
        )

        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true

        beaconLocationManager.startRangingBeacons(in: beaconRegion)

    }

    // MARK: UI

    func setupProximityLabel() {
        proximityLabel.textColor = .black
        proximityLabel.font = UIFont.systemFont(ofSize: 17)
        proximityLabel.textAlignment = .center
        proximityLabel.text = NSLocalizedString(
            "Proximity: not ranging yet",
            comment: "proximity Label in BeaconVC"
        )

        proximityLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            proximityLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            proximityLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            proximityLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            proximityLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    func setupBackButton() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        backButton.setTitle(
            NSLocalizedString("Back", comment: "button in BeaconVC"),
            for: .normal
        )

        backButton.setTitleColor(.white, for: .normal)
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)

        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)

        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor),
            backButton.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            backButton.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            backButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    @objc func back() {
        dismiss(animated: true, completion: nil)
    }


}

extension BeaconViewController: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        monitoringDidFailFor region: CLRegion?,
        withError error: Error
    ) {
        print("Failed monitoring region: \(error.localizedDescription)")
        // ToDo: show Alert to user that need Always
        if let region = region {
            manager.stopMonitoring(for: region)
            return
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Location manager failed: \(error.localizedDescription)")
        if let error = error as? CLError,
            error.code == .denied {
            // ToDo: stop region monitoring/beacon ranging, alert -> open setting
            return
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        rangingBeaconsDidFailFor
        region: CLBeaconRegion,
        withError error: Error
    ) {
        print(error.localizedDescription)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didStartMonitoringFor region: CLRegion
    ) {
        print("didStartMonitoringFor")

        manager.requestState(for: region)
    }

    // the location manager calls the method whenever there is a boundary transition for a region
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("didDetermineState")
        if state == CLRegionState.inside {
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(in: region as! CLBeaconRegion)
            } else {
                proximityLabel.text = NSLocalizedString(
                    "Beacon ranging is not supported",
                    comment: "proximity Label in BeaconVC"
                )
            }
        } else {
            print("outside the region or unknown")
            manager.stopRangingBeacons(in: region as! CLBeaconRegion)
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didEnterRegion region: CLRegion
    ) {
        if CLLocationManager.isRangingAvailable() {
            print("in DidEnterRegion")
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
        } else {
            // ToDo: show
            print("Beacon ranging is not supported")
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didExitRegion region: CLRegion
    ) {
        print("in didExitRegion")

        if let beaconRegion = region as? CLBeaconRegion {
            manager.stopRangingBeacons(in: beaconRegion)
        } else {
            print("not beacon Region")
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didRangeBeacons beacons: [CLBeacon],
        in region: CLBeaconRegion
    ) {
        if beacons.count > 0 {
            let nearestBeacon = beacons[0]
            let major = CLBeaconMajorValue(truncating: nearestBeacon.major)
            let minor = CLBeaconMinorValue(truncating: nearestBeacon.minor)

            print("Major: \(major) (floor)")
            print("Minor: \(minor)")
            print("Distance: \(nearestBeacon.accuracy) (meters)")

            switch nearestBeacon.proximity {
            case .immediate:
                proximityLabel.text = NSLocalizedString(
                    "Proximity: immediate",
                    comment: "proximity Label in BeaconVC"
                )
                print("Proximity: immediate")

            case .near:
                proximityLabel.text = NSLocalizedString(
                    "Proximity: near",
                    comment: "proximity Label in BeaconVC"
                )
                print("Proximity: near")
            case .far:
                proximityLabel.text = NSLocalizedString(
                    "Proximity: far",
                    comment: "proximity Label in BeaconVC"
                )
                print("Proximity: far")
            default:
                proximityLabel.text = NSLocalizedString(
                    "Beacon is not found",
                    comment: "proximity Label in BeaconVC"
                )
                print("beacon with UUID \(nearestBeacon.proximityUUID), major: \(nearestBeacon.major), minor: \(nearestBeacon.minor) is not found")
            }
        } else {
            print("There is no Beacon detected")
        }
    }



}
