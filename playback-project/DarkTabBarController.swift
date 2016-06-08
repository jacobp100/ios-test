//
//  DarkTabBarController.swift
//  playback-project
//
//  Created by Jacob Parker on 01/06/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit

class DarkTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.barStyle = .Black
        tabBar.translucent = true
        tabBar.tintColor = UIColor.whiteColor()
    }

}
