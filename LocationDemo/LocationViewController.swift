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
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let locationManager = CLLocationManager()
    let cellIdentifier = "demoItems"
    var demoItems: [String] = [
        NSLocalizedString(
            "iBeacon (Indoor)",
            comment: "in TableView"
        ),
        NSLocalizedString(
            "requestLocation(once)",
            comment: "in TableView"
        ),
        NSLocalizedString(
            "startUpdatingLocation",
            comment: "in TableView"
        ),
        NSLocalizedString(
            "Background",
            comment: "in TableView"
        )
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        setupTableView()

        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
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
            let location = locations.first as? CLLocation
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

//        let myAnnotation = MKPointAnnotation()
//        myAnnotation.coordinate = CLLocationCoordinate2D(
//            latitude: location.coordinate.latitude,
//            longitude: location.coordinate.longitude
//        )
//        myAnnotation.title = NSLocalizedString("me", comment: "user location in mapView")
//        mapView.addAnnotation(myAnnotation)

        print("----User's Location----")
        print("latitude: \(location.coordinate.latitude)")
        print("longitude: \(location.coordinate.longitude)")
        print("altitude: \(location.altitude) meters")
        print("timestamp: \(location.timestamp)")
        print("speed: \(location.speed)")
        print("course: \(location.course)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("heading: \(newHeading.)")
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
        cell.itemLabel.text = demoItems[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            // present iBeacon Page
            let beaconVC = BeaconViewController()
            self.present(beaconVC, animated: true, completion: nil)
        case 1:
            locationManager.requestLocation()
        case 2:
            break
        case 3:
            break
        default:
            break
        }
    }

}

