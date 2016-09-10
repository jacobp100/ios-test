//
//  LoopViewController.swift
//  playback-project
//
//  Created by Jacob Parker on 07/06/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit

class LoopViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!

    var musicPlayer: MusicPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.contentSize.height =
            stackView.frame.height +
            bottomLayoutGuide.length +
            scrollView.layoutMargins.bottom
    }

    @IBAction func loopSwitchDidToggle(sender: UISwitch) {
        if !sender.on {
            // Set loop to nil
        } else if let currentItem = musicPlayer?.currentItem, let duration = currentItem.duration {
            let currentTime = currentItem.time
            let start = min(currentTime, duration - 30)
            let end = min(currentTime + 30, duration)
            let loop = Loop(start: start, end: end)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
