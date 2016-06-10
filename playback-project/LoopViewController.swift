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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
