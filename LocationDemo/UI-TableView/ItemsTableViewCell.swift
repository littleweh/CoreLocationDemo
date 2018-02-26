//
//  ItemsTableViewCell.swift
//  LocationDemo
//
//  Created by 典萱 高 on 2018/2/24.
//  Copyright © 2018年 LostRfounds. All rights reserved.
//

import UIKit

class ItemsTableViewCell: UITableViewCell {

    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var itemLabel: UILabel!
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if !stopButton.isHidden {
            sender.backgroundColor = .black
        }
    }
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        startButton.backgroundColor = UIColor(
            red: 0.0,
            green: 150/255.0,
            blue: 1.0,
            alpha: 1.0
        )
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        startButton.layer.cornerRadius = 0.2 * startButton.frame.height
        stopButton.layer.cornerRadius = 0.2 * stopButton.frame.height
        startButton.clipsToBounds = true
        stopButton.clipsToBounds = true
    }

}
