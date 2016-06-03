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
    private var kvoContext: UInt8 = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        musicPlayer.addObserver(
            self,
            forKeyPath: "currentIndex",
            options: .New,
            context: &kvoContext
        )

        displayLink = CADisplayLink(target: self, selector: #selector(ViewController.updateTime))
        displayLink!.paused = false
        displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)

        separatorConstraint.constant = 1 / UIScreen.mainScreen().scale
        playbackSlider?.delegate = self

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

        let bundle = NSBundle.mainBundle()
        let demoFile1 = MusicItem(
            title: "May the Force be with You",
            url: bundle.URLForResource("may-the-force-be-with-you", withExtension: "mp3")!
        )
        let demoFile2 = MusicItem(
            title: "Imperial March",
            url: bundle.URLForResource("imperial-march", withExtension: "mp3")!
        )

        musicPlayer.addFiles([demoFile1, demoFile2])
        musicPlayer.currentIndex = 0

        handleMediaItemUpdates()
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

    override func observeValueForKeyPath(
        keyPath: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>
    ) {
        handleMediaItemUpdates()
    }

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if let playlistViewController = viewController as? PlaylistViewController {
            playlistViewController.musicPlayer = musicPlayer
        } else if let pitchTempoViewController = viewController as? PitchTempoViewController {
            pitchTempoViewController.musicPlayer = musicPlayer
        } else if let jumpListTableViewController = viewController as? JumpListTableViewController {
            jumpListTableViewController.musicPlayer = musicPlayer
        }
    }

    func playSliderDidTogglePlaying(playSlider: PlaySlider) {
        musicPlayer.play()
    }

    func playSliderValueDidChange(playSlider: PlaySlider, value: Double) {
        playbackSlider.currentTime = value // Stop jumping back whilst loading
        musicPlayer.seek(value)
    }

    func handleMediaItemUpdates() {
        if let currentItem = musicPlayer.currentItem {
            songLabel.text = currentItem.title
        } else if musicPlayer.playlist.count > 0 {
            songLabel.text = musicPlayer.playlist[0].title
        } else {
            songLabel.text = ""
        }
        playbackSlider.totalDuration = musicPlayer.totalDuration ?? 1
    }

    func updateTime() {
        playbackSlider.currentTime = musicPlayer.currentTime
    }

}

