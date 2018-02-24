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
    let locationManager = CLLocationManager()

    let mapView = MKMapView()
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mapView)
        self.view.addSubview(tableView)
        self.mapView.delegate = self
        self.tableView.delegate = self

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMapView()
        setupTableView()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self

            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            locationManager.requestLocation()
//            locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }

    }

    func setupMapView() {
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true

        mapView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            mapView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            mapView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5)
        ])
    }

    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor)
        ])

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

        print("coordinate: \(location.coordinate)")
        print("altitude: \(location.altitude) meters")
        print("timestamp: \(location.timestamp)")
        print("speed: \(location.speed)")
        print("course: \(location.course)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("heading: \(newHeading)")
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

extension LocationViewController: UITableViewDelegate {

}

