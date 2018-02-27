//
//  ViewController.swift
//  LocationDemo
//
//  Created by 典萱 高 on 2018/2/22.
//  Copyright © 2018年 LostRfounds. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationViewController: UIViewController {
    @IBOutlet weak var showTextLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var tableView: UITableView!

    let locationManager = CLLocationManager()
    let cellIdentifier = "demoItems"
    var previousLocation: CLLocation? // for distance calculation

    var demoItems: [DemoItems] = [
            DemoItems.beacon,
            DemoItems.locationOnce,
            DemoItems.locationUpdating,
            DemoItems.heading,
            DemoItems.significantChange,
            DemoItems.visit
    ]
    var selectedLocationService: DemoItems = DemoItems.none
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        setupTableView()

        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

            locationManager.distanceFilter = kCLDistanceFilterNone // default
//            locationManager.distanceFilter = 15 // meters
            locationManager.allowsBackgroundLocationUpdates = true

            locationManager.requestLocation()
        }

    }

    func authorizationRequest() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .restricted, .denied:
            let alertController = UIAlertController(
                title: NSLocalizedString(
                    "Background Location Access Disabled",
                    comment: "alert in LocationVC"
                ),
                message: NSLocalizedString(
                    "For background Location service Demo, please open this app's settings and set location access to 'Always'",
                    comment: "alert in LocationVC"
                ),
                preferredStyle: .alert)

            let cancelAction = UIAlertAction(
                title: NSLocalizedString(
                    "Cancel",
                    comment: "Alert action in LocationVC"
                ),
                style: .cancel,
                handler: nil
            )
            alertController.addAction(cancelAction)

            let openAction = UIAlertAction(
                title: NSLocalizedString(
                "Open Settings",
                comment: "Alert action in LocationVC"
                ),
                style: .default,
                handler: { (_) in
                    if let url = URL(string: UIApplicationOpenSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
            })
            alertController.addAction(openAction)

            self.present(alertController, animated: true, completion: nil)
        case .authorizedAlways:
            break
        }
    }

    // MARK: setup UI
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self

        let nib = UINib(nibName: "ItemsTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
    }

}

extension LocationViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location detection failed with \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        if let error = error {
            print("location deferred update failed with \(error.localizedDescription)")
        }

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.showsUserLocation = true

        var distance = 0.0

        guard
            let location = locations.last
            else { return }

        let center = CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )

        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(
                latitudeDelta: 0.01,
                longitudeDelta: 0.01
            )
        )

        self.mapView.setRegion(region, animated: true)

        var level = "N/A"
        if let floor = location.floor {
            level = "\(floor.level)"
        }

        if let previousLocation = self.previousLocation {
            distance = location.distance(from: previousLocation)
        }
        self.previousLocation = location

        let locationInfo = """
        ----User's Location----
        latitude: \(location.coordinate.latitude)
        longitude: \(location.coordinate.longitude)
        distance with previous location: \(distance) meters
        altitude: \(location.altitude) meters
        floor: \(level)
        timestamp: \(location.timestamp)
        speed: \(location.speed)
        course: \(location.course)
        """

        print(locationInfo)
        showTextLabel.text = locationInfo

        switch selectedLocationService {
        case .significantChange:
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            FirebaseRef.saveLocationInfoWith(
                location: location,
                databaseRef: FirebaseRef.databaseSignificantChange,
                dateFormatter: dateFormatter
            )
            let myAnnotation = MKPointAnnotation()
            myAnnotation.coordinate = CLLocationCoordinate2D(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            mapView.addAnnotation(myAnnotation)
        case .locationUpdating:
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            FirebaseRef.saveLocationInfoWith(
                location: location,
                databaseRef: FirebaseRef.databaseUpdatingLocations,
                dateFormatter: dateFormatter
            )
        default:
            break
        }
//        locationManager.allowDeferredLocationUpdates(untilTraveled: 0.0, timeout: 3.0)

    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateHeading newHeading: CLHeading
    ) {

        let headingInfo = """
        ----Device heading----
        magneticHeading: \(newHeading.magneticHeading) degree
        trueHeading: \(newHeading.trueHeading) degree
        accuracy: \(newHeading.headingAccuracy) (maximum deviation)
        x: \(newHeading.x)
        y: \(newHeading.y)
        z: \(newHeading.z)
        timestamp: \(newHeading.timestamp)
        """
        print(headingInfo)
        showTextLabel.text = headingInfo

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        FirebaseRef.saveHeadingInfoWith(
            newHeading: newHeading,
            databaseRef: FirebaseRef.databaseHeading,
            dateFormatter: dateFormatter
        )
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
            manager.requestAlwaysAuthorization()
            // if 'Always' is needed
            // use self.authorizationRequest() to open app's settings
        }
    }

    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        let visitInfo = """
        ----Visit----
        latitude: \(visit.coordinate.latitude)
        longitude: \(visit.coordinate.longitude)
        arrival date: \(visit.arrivalDate)
        departure date: \(visit.departureDate)
        horizontal accuracy: \(visit.horizontalAccuracy)
        """
        showTextLabel.text = visitInfo
        print(visitInfo)

//        let arrival = dateFormatter.string(from: visit.arrivalDate)
//        let departure = dateFormatter.string(from: visit.departureDate)

        let recordVisitReference = FirebaseRef.databaseVisits.child("test")
        let object: [String: Any] = [
            "coordinate": [
                "latitude": visit.coordinate.latitude,
                "longitude": visit.coordinate.longitude
            ],
//            "arrival_date": arrival,
//            "departure_date": departure,
            "arrival_date": "\(visit.arrivalDate)",
            "departure_date": "\(visit.departureDate)",
            "horizontal_accuracy": visit.horizontalAccuracy
        ]
        recordVisitReference
            .child("\(visit.arrivalDate)_" + DemoItems.visit.rawValue)
            .setValue(object)
    }

}

extension LocationViewController: MKMapViewDelegate {

}

extension LocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoItems.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemsTableViewCell
            else {
                return UITableViewCell()
        }
        cell.itemLabel.text = demoItems[indexPath.row].rawValue

        switch demoItems[indexPath.row] {
        case .beacon, .locationOnce:
            cell.stopButton.isHidden = true
        default:
            break
        }

        cell.startButton.addTarget(
            self,
            action: #selector(startFunction(_:)),
            for: .touchUpInside
        )
        cell.stopButton.addTarget(
            self,
            action: #selector(stopFunction(_:)),
            for: .touchUpInside
        )

        return cell
    }

    @objc func startFunction(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        var indexPath: IndexPath? = tableView.indexPathForRow(at: buttonPosition)

        guard
            let itemIndex = indexPath?.row
            else { return }

        selectedLocationService = demoItems[itemIndex]

        switch selectedLocationService {
        case .none:
            break
        case .beacon:
            let beaconVC = BeaconViewController()
            self.present(beaconVC, animated: true, completion: nil)
        case .locationOnce:
            print("---------------------------------")
            print("request user's location only once")
            print("---------------------------------")
            locationManager.requestLocation()
        case .locationUpdating:
            print("---------------------------------")
            print("keep updating user's locations")
            print("---------------------------------")
            locationManager.startUpdatingLocation()
        case .heading:
            print("---------------------------------")
            print("keep updating user's heading")
            print("---------------------------------")
            locationManager.headingFilter = 3 // degree
            locationManager.headingOrientation = .portrait // default

            locationManager.startUpdatingHeading()
        case .significantChange:
            if CLLocationManager.authorizationStatus() != .authorizedAlways {
                self.authorizationRequest()
                sender.backgroundColor = ColorUsed.paBlue
                print("open settings.......")
            } else {
                if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
                    print("need Always authorization")
                } else {
                    print("---------------------------------")
                    print("Significant-change location service")
                    print("---------------------------------")
                    locationManager.startMonitoringSignificantLocationChanges()
                }
            }
        case .visit:
            if CLLocationManager.authorizationStatus() != .authorizedAlways {
                self.authorizationRequest()
                sender.backgroundColor = ColorUsed.paBlue
                print("open settings.......")
            } else {
                print("---------------------------------")
                print("start monitoring visits")
                print("---------------------------------")
                locationManager.startMonitoringVisits()
            }
        }

    }

    @objc func stopFunction(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        var indexPath: IndexPath? = tableView.indexPathForRow(at: buttonPosition)
        guard
            let itemIndex = indexPath?.row
            else { return }

        switch demoItems[itemIndex] {
        case .beacon, .locationOnce, .none:
            break
        case .locationUpdating:
            print("---------------------------------")
            print("stop updating user's locations")
            print("---------------------------------")
            locationManager.stopUpdatingLocation()
        case .heading:
            print("---------------------------------")
            print("stop updating user's heading")
            print("---------------------------------")
            locationManager.stopUpdatingHeading()
        case .significantChange:
            print("---------------------------------")
            print("stop monitoring significant location change")
            print("---------------------------------")
            locationManager.stopMonitoringSignificantLocationChanges()
        case .visit:
            print("---------------------------------")
            print("stop monitoring visits")
            print("---------------------------------")
            locationManager.stopMonitoringVisits()
        }
        selectedLocationService = .none

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch demoItems[indexPath.row] {
        case .significantChange:
            if let significantChangeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignificantChangeVC") as? SignificantChangeViewController {
                present(significantChangeVC, animated: true, completion: nil)
            }
        default:
            break
        }
    }

}
