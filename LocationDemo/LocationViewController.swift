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
    let headerIdentifier = "ItemsHeaderCell"
    let cellIdentifier = "demoItems"

    var demoItems: [DemoItems] = [
            DemoItems.Beacon,
            DemoItems.LocationOnce,
            DemoItems.LocationUpdating,
            DemoItems.Heading,
            DemoItems.SignificantChange,
    ]
    var selectedLocationService: DemoItems = DemoItems.None

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        setupTableView()

        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.requestLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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

        let myAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        mapView.addAnnotation(myAnnotation)

        print("----User's Location----")
        var level = "N/A"
        if let floor = location.floor {
            level = "\(floor.level)"
        }
        print("latitude: \(location.coordinate.latitude)")
        print("longitude: \(location.coordinate.longitude)")
        print("altitude: \(location.altitude) meters")
        print("floor: \(level)")
        print("timestamp: \(location.timestamp)")
        print("speed: \(location.speed)")
        print("course: \(location.course)")

        showTextLabel.text = """
        ----User's Location----
        latitude: \(location.coordinate.latitude)
        longitude: \(location.coordinate.longitude)
        altitude: \(location.altitude) meters
        floor: \(level)
        timestamp: \(location.timestamp)
        speed: \(location.speed)
        course: \(location.course)
        """
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("----Device heading----")
        print("magneticHeading: \(newHeading.magneticHeading) degree")
        print("trueHeading: \(newHeading.trueHeading) degree")
        print("accuracy: \(newHeading.headingAccuracy) (maximum deviation)")
        print("x: \(newHeading.x)")
        print("y: \(newHeading.y)")
        print("z: \(newHeading.z)")
        print("timestamp: \(newHeading.timestamp)")

        showTextLabel.text = """
        ----Device heading----
        magneticHeading: \(newHeading.magneticHeading) degree
        trueHeading: \(newHeading.trueHeading) degree
        accuracy: \(newHeading.headingAccuracy) (maximum deviation)
        x: \(newHeading.x)
        y: \(newHeading.y)
        z: \(newHeading.z)
        timestamp: \(newHeading.timestamp)
        """
    }

    // if user not allow location service authorization, use this to open settings
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
            self.showLocationDisabledPopup()
        }
    }

    func showLocationDisabledPopup() {
        let alertController = UIAlertController(
            title: "Background location Access Disabled",
            message: "we need your location",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        alertController.addAction(cancelAction)

        let openAction = UIAlertAction(
            title: "Open Settings",
            style: .default
        ) { (actin) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)

        self.present(
            alertController,
            animated: true,
            completion: nil
        )
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
        case .Beacon, .LocationOnce:
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
        case .None:
            break
        case .Beacon:
            let beaconVC = BeaconViewController()
            self.present(beaconVC, animated: true, completion: nil)
        case .LocationOnce:
            print("---------------------------------")
            print("request user's location only once")
            print("---------------------------------")
            locationManager.requestLocation()
        case .LocationUpdating:
            print("---------------------------------")
            print("keep updating user's locations")
            print("---------------------------------")
            locationManager.startUpdatingLocation()
        case .Heading:
            print("---------------------------------")
            print("keep updating user's heading")
            print("---------------------------------")
            locationManager.startUpdatingHeading()
        case .SignificantChange:
            if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
                print("need Always authorization")
            } else {
                locationManager.distanceFilter = 1 // meters
                let thresholds = locationManager.distanceFilter
                print("---------------------------------")
                print("Significant-change location service with \(thresholds) meter(s)")
                print("---------------------------------")
                locationManager.startMonitoringSignificantLocationChanges()
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
        case .Beacon, .LocationOnce, .None:
            break
        case .LocationUpdating:
            print("---------------------------------")
            print("stop updating user's locations")
            print("---------------------------------")
            locationManager.stopUpdatingLocation()
        case .Heading:
            print("---------------------------------")
            print("stop updating user's heading")
            print("---------------------------------")
            locationManager.stopUpdatingHeading()
        case .SignificantChange:
            print("---------------------------------")
            print("stop monitoring significant location change")
            print("---------------------------------")
            locationManager.stopMonitoringSignificantLocationChanges()
        }
        selectedLocationService = .None

    }

}

