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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(backButton)
        setupBackButton()

    }

    deinit {
        print("BeaconVC is dead")
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
