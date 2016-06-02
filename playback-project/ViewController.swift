//
//  ViewController.swift
//  playback-project
//
//  Created by Jacob Parker on 14/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, PlaySliderDelegate, UITabBarControllerDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var playbackSlider: PlaySlider!
    @IBOutlet weak var separatorConstraint: NSLayoutConstraint!

    private var musicPlayer = MusicPlayer()
    private var displayLink: CADisplayLink?

    override func viewDidLoad() {
        super.viewDidLoad()

        displayLink = CADisplayLink(target: self, selector: #selector(ViewController.updateTime))
        displayLink!.paused = false
        displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)

        separatorConstraint.constant = 1 / UIScreen.mainScreen().scale
        playbackSlider?.delegate = self

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

        let bundle = NSBundle.mainBundle()
        let demoFile = MusicItem(
            title: "Starwars",
            url: bundle.URLForResource("starwars", withExtension: "mp3")!
        )

        musicPlayer.addFiles([demoFile])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embed" {
            let tabBarController = segue.destinationViewController as! UITabBarController
            tabBarController.delegate = self

            if let selectedViewController = tabBarController.viewControllers?.first {
                self.tabBarController(
                    tabBarController,
                    didSelectViewController: selectedViewController
                )
            }
        }
    }

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if let playlistViewController = viewController as? PlaylistViewController {
            playlistViewController.musicPlayer = musicPlayer
        } else if let pitchTempoViewController = viewController as? PitchTempoViewController {
            pitchTempoViewController.musicPlayer = musicPlayer
        }
    }

    func playSliderDidTogglePlaying(playSlider: PlaySlider) {
        musicPlayer.play()
    }

    func playSliderValueDidChange(playSlider: PlaySlider, value: Double) {
        playbackSlider.currentTime = value // Stop jumping back whilst loading
        musicPlayer.seek(value)
    }

    func updateTime() {
        playbackSlider.currentTime = musicPlayer.currentTime
    }

}

