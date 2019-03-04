//
//  ViewController.swift
//  ToggleButton
//
//  Created by Tuan Tran on 04/03/2019.
//  Copyright © 2019 Tuan Tran. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak private var toggleButton1: ToggleButton!
    @IBOutlet weak private var toggleButton2: ToggleButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    private func setupViews() {
        toggleButton1.contentSizeMode = .wrapText


        toggleButton2.isRoundCorner = false
        toggleButton2.contentSizeMode = .equalize
    }
}
