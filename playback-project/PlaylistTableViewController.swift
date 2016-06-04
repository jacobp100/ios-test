//
//  PlaylistViewController.swift
//  playback-project
//
//  Created by Jacob Parker on 31/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit
import MediaPlayer


enum PlaylistActionHandler {
    case AddMediaItems
    case ClearPlaylist
}

class PlaylistAction {
    var title: String!
    var image: String!
    var action: PlaylistActionHandler

    init(title: String, image: String, action: PlaylistActionHandler) {
        self.title = title
        self.image = image
        self.action = action
    }
}

class PlaylistTableViewController: UITableViewController, MPMediaPickerControllerDelegate {

    var musicPlayer: MusicPlayer? {
        didSet {
            reload()

            if oldValue != nil {
                removeEvents()
            }

            if let currentMusicPlayer = musicPlayer {
                addEventListeners(
                    selector: #selector(PlaylistTableViewController.reload),
                    events: [MusicPlayer.ITEM_DID_CHANGE, MusicPlayer.PLAYLIST_DID_CHANGE],
                    object: currentMusicPlayer
                )
            }
        }
    }

    private var mediaPicker: MPMediaPickerController?
    private let actions: [PlaylistAction] = [
        PlaylistAction(title: "Add from Library", image: "tableview-add", action: .AddMediaItems),
        PlaylistAction(title: "Clear Playlist", image: "tableview-clear", action: .ClearPlaylist),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0
            ? actions.count
            : musicPlayer?.playlist.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaylistCell", forIndexPath: indexPath)

        cell.imageView?.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(
            red: 218 / 255,
            green: 236 / 255,
            blue: 87 / 255,
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
            cell.imageView?.image = playbackMusicPlayer.currentIndex == indexPath.row
                ? UIImage(named: "tableview-speaker")
                : UIImage(named: "tableview-blank")
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            switch actions[indexPath.row].action {
            case .AddMediaItems:
                showMediaPicker()
            default:
                break
            }
        } else {
            musicPlayer?.playAtIndex(indexPath.row)
            deselect()
        }
    }

    func deselect() {
        if let selectedPath = tableView?.indexPathForSelectedRow {
            tableView?.deselectRowAtIndexPath(selectedPath, animated: false)
        }
    }

    func reload() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView?.reloadData()
        }
    }

    func showMediaPicker() {
        mediaPicker = MPMediaPickerController(mediaTypes: .AnyAudio)

        if let picker = mediaPicker {
            picker.delegate = self

            presentViewController(picker, animated: true, completion: nil)
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        }
    }

    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        // mediaItemCollection.items[0].title
        mediaPickerDidCancel(mediaPicker)
    }

    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        deselect()
    }

}
