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
    let cellIdentifier = "SignificantChangeCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupTableView()

        locationManager.delegate = self
        mapView.delegate = self

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

}

extension SignificantChangeViewController: MKMapViewDelegate {

}

extension SignificantChangeViewController: CLLocationManagerDelegate {

}

extension SignificantChangeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SignificantChangeTableViewCell
        else { return UITableViewCell()}
        return cell
    }

}
