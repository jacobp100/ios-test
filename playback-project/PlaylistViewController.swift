//
//  PlaylistViewController.swift
//  playback-project
//
//  Created by Jacob Parker on 31/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit

protocol PlaylistViewControllerDelegate {
    func playlistDidSelectItem(sender: PlaylistViewController, item: AnyObject)
}

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView?

    private var kvoContext: UInt8 = 1

    var musicPlayer: MusicPlayer? {
        didSet {
            tableView?.reloadData()

            if let previousMusicPlayer = oldValue {
                previousMusicPlayer.removeObserver(self, forKeyPath: "currentItem")
                previousMusicPlayer.removeObserver(self, forKeyPath: "playlist")
            }

            if let currentMusicPlayer = musicPlayer {
                currentMusicPlayer.addObserver(
                    self,
                    forKeyPath: "currentItem",
                    options: .New,
                    context: &kvoContext
                )
                currentMusicPlayer.addObserver(
                    self,
                    forKeyPath: "playlist",
                    options: .New,
                    context: &kvoContext
                )
            }
        }
    }

    private let actionTitles = [
        "Add from Library",
        "Clear Playlist"
    ]
    private let actionImages = [
        "tableview-add",
        "tableview-clear"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView?.backgroundColor = UIColor.clearColor()
        tableView?.delegate = self
        tableView?.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func observeValueForKeyPath(
        keyPath: String?,
        ofObject object: AnyObject?,
                 change: [String : AnyObject]?,
                 context: UnsafeMutablePointer<Void>
        ) {
        tableView?.reloadData()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0
            ? actionTitles.count
            : musicPlayer?.playlist.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        cell.imageView?.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(
            red: 175 / 255,
            green: 219 / 255,
            blue: 1 / 255,
            alpha: 1
        )
        cell.selectedBackgroundView = backgroundView

        cell.textLabel?.highlightedTextColor = UIColor.blackColor()

        if indexPath.section == 0 {
            cell.textLabel?.text = actionTitles[indexPath.row]
            cell.imageView?.image = UIImage(named: actionImages[indexPath.row])
        } else if let playbackMusicPlayer = musicPlayer {
            let rowMediaItem = playbackMusicPlayer.playlist[indexPath.row]
            cell.textLabel?.text = rowMediaItem.title

            if let currentItem = playbackMusicPlayer.currentItem where currentItem.url == rowMediaItem.url {
                cell.imageView?.image = UIImage(named: "tableview-speaker")
            } else {
                cell.imageView?.image = UIImage(named: "tableview-blank")
            }
        }

        return cell
    }

}
