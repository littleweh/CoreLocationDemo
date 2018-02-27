//
//  SignificantChangeViewController.swift
//  LocationDemo
//
//  Created by 典萱 高 on 2018/2/26.
//  Copyright © 2018年 LostRfounds. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class SignificantChangeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backButton: UIButton!

    let locationManager = CLLocationManager()
    let locationsProvider = LocationsProvider()
    let cellIdentifier = "SignificantChangeCell"

    var significantChangelocations: [CLLocation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupTableView()

        locationManager.delegate = self
        mapView.delegate = self
        locationsProvider.delegate = self

        locationsProvider.getSignificantChangeLocations()

    }

    // setupUI
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        let nib = UINib(nibName: "SignificantChangeTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
    }

    func setupBackButton() {
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    }

    @objc func back() {
        dismiss(animated: true, completion: nil)
    }

    // from: https://developer.apple.com/documentation/corelocation/converting_between_coordinates_and_user_friendly_place_names
    func lookUp(location: CLLocation, completionHandler: @escaping (CLPlacemark?)
        -> Void ) {
        let geocoder = CLGeocoder()

        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(
            location,
            completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstPlaceMark = placemarks?[0]
                    completionHandler(firstPlaceMark)
                } else {
                    // An error occurred during geocoding.
                    completionHandler(nil)
                }
        })
    }

}

extension SignificantChangeViewController: MKMapViewDelegate {

}

extension SignificantChangeViewController: CLLocationManagerDelegate {

}

extension SignificantChangeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return significantChangelocations.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SignificantChangeTableViewCell
        else {
            return UITableViewCell()
        }
        let location = significantChangelocations[indexPath.row]
        let distance = indexPath.row == 0 ? 0: location.distance(from: significantChangelocations[indexPath.row-1])

        lookUp(location: location) { (placemark) in
            let locationInfo = """
            latitude: \(location.coordinate.latitude)
            longitude: \(location.coordinate.longitude)
            distance with previous location: \(distance)
            name: \(placemark?.name ?? "")
            date: \(location.timestamp)
            """
            cell.locationInfoLabel.text = locationInfo
            print("-----------")
            print(locationInfo)
            print("-----------")

        }

        return cell

    }

}

extension SignificantChangeViewController: LocationsProviderDelegate {
    func locationsProvider(_ locationsProvider: LocationsProvider, didGet locations: [CLLocation]) {
        self.significantChangelocations = locations
        tableView.reloadData()
    }

}
