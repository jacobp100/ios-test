//
//  ViewController.swift
//  playback-project
//
//  Created by Jacob Parker on 14/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit
import AVFoundation


extension UIViewController {
    func addEventListeners(selector aSelector: Selector, events: [String], object: AnyObject?) {
        events.forEach {
            event in
            NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: aSelector,
                name: event,
                object: object
            )
        }
    }
    func removeEvents() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


class ViewController: UIViewController, PlaySliderDelegate, UITabBarControllerDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var playbackSlider: PlaySlider!
    @IBOutlet weak var separatorConstraint: NSLayoutConstraint!

    private var musicPlayer = MusicPlayer()
    private var displayLink: CADisplayLink?

    private var demoJumplistItemsForSong: [Double] = [
        30,
        45,
        80,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        addEventListeners(
            selector: #selector(ViewController.handleMediaItemUpdates),
            events: [MusicPlayer.ITEM_DID_LOAD, MusicPlayer.ITEM_DID_CHANGE],
            object: musicPlayer
        )

        displayLink = CADisplayLink(target: self, selector: #selector(ViewController.updateTime))
        displayLink!.paused = false
        displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)

        separatorConstraint.constant = 1 / UIScreen.mainScreen().scale
        playbackSlider.delegate = self
        playbackSlider.jumplistItems = demoJumplistItemsForSong

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

        let bundle = NSBundle.mainBundle()
        let demoFile1 = MusicPlayerAudioFile(
            title: "May the Force be with You",
            url: bundle.URLForResource("may-the-force-be-with-you", withExtension: "mp3")!
        )
        let demoFile2 = MusicPlayerAudioFile(
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

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if let playlistTableViewController = viewController as? PlaylistTableViewController {
            playlistTableViewController.musicPlayer = musicPlayer
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
        playbackSlider.time = value // Stop jumping back whilst loading
        musicPlayer.seek(value)
    }

    func handleMediaItemUpdates() {
        dispatch_async(dispatch_get_main_queue()) {
            if let currentItem = self.musicPlayer.currentItem {
                self.songLabel.text = currentItem.title
            } else if self.musicPlayer.playlist.count > 0 {
                self.songLabel.text = self.musicPlayer.playlist[0].title
            } else {
                self.songLabel.text = ""
            }
            self.playbackSlider.duration = self.musicPlayer.currentItem?.duration
        }
    }

    func updateTime() {
        playbackSlider.time = musicPlayer.currentItem?.time ?? 0
    }

}

