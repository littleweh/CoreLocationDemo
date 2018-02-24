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
    override func awakeFromNib() {
        super.awakeFromNib()
        startButton.layer.cornerRadius = 0.2 * startButton.frame.height
        stopButton.layer.cornerRadius = 0.2 * stopButton.frame.height
        startButton.clipsToBounds = true
        stopButton.clipsToBounds = true
    }
    
}
