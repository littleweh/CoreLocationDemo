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
    let monitorRegionButton = UIButton()
    let rangingBeaconButton = UIButton()
    let proximityLabel = UILabel()
    let beaconUUID: String = "A83CA210-A397-466B-B694-5181EE035A2C"

    let beaconLocationManager = CLLocationManager()

    var isMonitoringRegion: Bool = false
    var isRangingBeacon: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(backButton)
        self.view.addSubview(proximityLabel)
        self.view.addSubview(monitorRegionButton)
        self.view.addSubview(rangingBeaconButton)
        setupBackButton()
        setupProximityLabel()
        setupMonitorRegionButton()
        setupRangingBeaconButton()

        beaconLocationManager.delegate = self

        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways {
                beaconLocationManager.requestAlwaysAuthorization()
            }
        }
    }

    deinit {
        print("BeaconVC is dead")
    }

    // MARK: Beacon region monitoring, ranging

    @objc func monitorBeaconRegion() {
        if let uuid = UUID(uuidString: beaconUUID) {
            let beaconRegion = CLBeaconRegion(
                proximityUUID: uuid,
                identifier: ""
            )

            beaconRegion.notifyOnEntry = true
            beaconRegion.notifyOnExit = true

            if !isMonitoringRegion {
                beaconLocationManager.startMonitoring(for: beaconRegion)

                print("--------------")
                print("start monitoring beacon region")
                print("--------------")

                monitorRegionButton.setTitle(
                    NSLocalizedString(
                        "stop monitoring",
                        comment: "button in beaconVC"),
                    for: .normal
                )
                monitorRegionButton.backgroundColor = .blue

            } else {
                beaconLocationManager.stopMonitoring(for: beaconRegion)

                print("--------------")
                print("stop monitoring beacon region")
                print("--------------")

                monitorRegionButton.setTitle(
                    NSLocalizedString(
                        "start monitoring",
                        comment: "button in beaconVC"),
                    for: .normal
                )
                monitorRegionButton.backgroundColor = .black
            }
            isMonitoringRegion = !isMonitoringRegion

        } else {
            proximityLabel.text = NSLocalizedString(
                "Please setup an iBeacon with UUID: \(beaconUUID)",
                comment: "proximity Label in BeaconVC"
            )
        }
    }

    @objc func rangingBeacons() {
        if let uuid = UUID(uuidString: beaconUUID) {
            let beaconRegion = CLBeaconRegion(
                proximityUUID: uuid,
                identifier: ""
            )

            beaconRegion.notifyOnEntry = true
            beaconRegion.notifyOnExit = true

            if !isRangingBeacon {
                beaconLocationManager.startRangingBeacons(in: beaconRegion)

                print("--------------")
                print("start ranging beacon region")
                print("--------------")

                rangingBeaconButton.setTitle(
                    NSLocalizedString(
                        "stop ranging",
                        comment: "button in beaconVC"),
                    for: .normal
                )
                rangingBeaconButton.backgroundColor = .blue
            } else {
                beaconLocationManager.stopRangingBeacons(in: beaconRegion)

                print("--------------")
                print("stop ranging beacon region")
                print("--------------")

                rangingBeaconButton.setTitle(
                    NSLocalizedString(
                        "start ranging",
                        comment: "button in beaconVC"),
                    for: .normal
                )
                rangingBeaconButton.backgroundColor = .black
            }
            isRangingBeacon = !isRangingBeacon
        } else {
            proximityLabel.text = NSLocalizedString(
                "Please setup an iBeacon with UUID: \(beaconUUID)",
                comment: "proximity Label in BeaconVC"
            )
        }

    }

    // MARK: UI

    func setupMonitorRegionButton() {
        monitorRegionButton.translatesAutoresizingMaskIntoConstraints = false
        monitorRegionButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        monitorRegionButton.setTitle(
            NSLocalizedString("start monitoring", comment: "button in BeaconVC"),
            for: .normal
        )

        monitorRegionButton.setTitleColor(.white, for: .normal)
        monitorRegionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)

        monitorRegionButton.addTarget(self, action: #selector(monitorBeaconRegion), for: .touchUpInside)

        NSLayoutConstraint.activate([
            monitorRegionButton.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: -8),
            monitorRegionButton.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            monitorRegionButton.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            monitorRegionButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    func setupRangingBeaconButton(){
        rangingBeaconButton.translatesAutoresizingMaskIntoConstraints = false
        rangingBeaconButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        rangingBeaconButton.setTitle(
            NSLocalizedString("start ranging", comment: "button in BeaconVC"),
            for: .normal
        )

        rangingBeaconButton.setTitleColor(.white, for: .normal)
        rangingBeaconButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)

        rangingBeaconButton.addTarget(self, action: #selector(rangingBeacons), for: .touchUpInside)

        NSLayoutConstraint.activate([
            rangingBeaconButton.bottomAnchor.constraint(equalTo: monitorRegionButton.topAnchor, constant: -8),
            rangingBeaconButton.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            rangingBeaconButton.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            rangingBeaconButton.heightAnchor.constraint(equalToConstant: 30)
            ])

    }

    func setupProximityLabel() {
        proximityLabel.textColor = .black
        proximityLabel.font = UIFont.systemFont(ofSize: 17)
        proximityLabel.textAlignment = .center
        proximityLabel.numberOfLines = 0
        proximityLabel.text = NSLocalizedString(
            "Proximity: not ranging yet",
            comment: "proximity Label in BeaconVC"
        )

        proximityLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            proximityLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            proximityLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            proximityLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            proximityLabel.heightAnchor.constraint(equalToConstant: 200)
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
        print("didStartMonitoringForRegion")

        manager.requestState(for: region)
    }

    // the location manager calls the method whenever there is a boundary transition for a region
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == CLRegionState.inside {
            print("region inside")
            if CLLocationManager.isRangingAvailable() {
                // swiftlint:disable force_cast
                print("region inside, start ranging beacons")
                manager.startRangingBeacons(in: region as! CLBeaconRegion)
                // swiftlint:enable force_cast
            } else {
                proximityLabel.text = NSLocalizedString(
                    "Beacon ranging is not supported",
                    comment: "proximity Label in BeaconVC"
                )
            }
        } else {
            print("unknown/ region outside")
            // swiftlint:disable force_cast
            manager.stopRangingBeacons(in: region as! CLBeaconRegion)
            // swiftlint:enable force_cast
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didEnterRegion region: CLRegion
    ) {
        if CLLocationManager.isRangingAvailable() {
            print("enter the region, start ranging beacons")
            // swiftlint:disable force_cast
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
            // swiftlint:enable force_cast
        } else {
            // ToDo: show
            print("Beacon ranging is not supported")
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didExitRegion region: CLRegion
    ) {
        print("exited the Region")

        if let beaconRegion = region as? CLBeaconRegion {
            manager.stopRangingBeacons(in: beaconRegion)
        } else {
            print("not in beacon Region")
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

            let beaconInfo = """
            Major: \(major) (e.g. floor)
            Minor: \(minor)
            Distance: \(nearestBeacon.accuracy) (meters)
            """
            print(beaconInfo)

            switch nearestBeacon.proximity {
            case .immediate:
                proximityLabel.text = NSLocalizedString(
                    beaconInfo +
                    """

                    Proximity: immediate
                    """,
                    comment: "proximity Label in BeaconVC"
                )
                print("Proximity: immediate")

            case .near:
                proximityLabel.text = NSLocalizedString(
                    beaconInfo +
                    """

                    Proximity: near
                    """,
                    comment: "proximity Label in BeaconVC"
                )
                print("Proximity: near")
            case .far:
                proximityLabel.text = NSLocalizedString(
                    beaconInfo +
                    """

                    Proximity: far
                    """,
                    comment: "proximity Label in BeaconVC"
                )
                print("Proximity: far")
            default:
                proximityLabel.text = NSLocalizedString(
                    beaconInfo +
                    """

                    Beacon is not found
                    """,
                    comment: "proximity Label in BeaconVC"
                )
                print("beacon with UUID \(nearestBeacon.proximityUUID), major: \(nearestBeacon.major), minor: \(nearestBeacon.minor) is not found")
            }
        } else {
            print("There is no Beacon detected")
        }
    }

}
