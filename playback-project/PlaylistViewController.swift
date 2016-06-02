//
//  PlaylistViewController.swift
//  playback-project
//
//  Created by Jacob Parker on 31/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit
import MediaPlayer

enum StaticActionHandler {
    case AddMediaItems
    case ClearPlaylist
}

class StaticAction {
    var title: String!
    var image: String!
    var action: StaticActionHandler

    init(title: String, image: String, action: StaticActionHandler) {
        self.title = title
        self.image = image
        self.action = action
    }
}

class PlaylistViewController: UIViewController, MPMediaPickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {

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

    private var mediaPicker: MPMediaPickerController?
    private let actions: [StaticAction] = [
        StaticAction(title: "Add from Library", image: "tableview-add", action: .AddMediaItems),
        StaticAction(title: "Clear Playlist", image: "tableview-clear", action: .ClearPlaylist),
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
            ? actions.count
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
            let action = actions[indexPath.row]
            cell.textLabel?.text = action.title
            cell.imageView?.image = UIImage(named: action.image)
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

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            switch actions[indexPath.row].action {
            case .AddMediaItems:
                showMediaPicker()
            default:
                break
            }
        }
    }

    func showMediaPicker() {
        mediaPicker = MPMediaPickerController(mediaTypes: .AnyAudio)

        if let picker = mediaPicker {
            picker.delegate = self
//            view.addSubview(picker.view)

            presentViewController(picker, animated: true, completion: nil)
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        }
    }

    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        // mediaItemCollection.items[0].title
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }

    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }

}
