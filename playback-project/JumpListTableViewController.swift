//
//  JumpListTableViewController.swift
//  playback-project
//
//  Created by Jacob Parker on 03/06/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit
import CoreData


enum JumpListActionHandler {
    case AddJumpListItem
}

class JumpListAction {
    var title: String!
    var action: JumpListActionHandler

    init(title: String, action: JumpListActionHandler) {
        self.title = title
        self.action = action
    }
}

class JumpListTableViewController: UITableViewController, PickTimeDelegate {

    var managedObjectContext: NSManagedObjectContext?

    var musicPlayer: MusicPlayer? {
        didSet {
            reload()

            if oldValue != nil {
                removeEvents()
            }

            if let currentMusicPlayer = musicPlayer {
                addEventListeners(
                    selector: #selector(JumpListTableViewController.reload),
                    events: [MusicPlayer.ITEM_DID_CHANGE, MusicPlayer.ITEM_DID_LOAD],
                    object: currentMusicPlayer
                )
            }
        }
    }

    private var actions: [JumpListAction] = [
        JumpListAction(title: "Bookmark Time", action: .AddJumpListItem)
    ]
    private var segueIdentifier = "CurrentTimeSelection"
    private var jumplistItems: [JumplistItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    deinit {
        removeEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0
            ? actions.count
            : jumplistItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("JumpListCell", forIndexPath: indexPath)

        cell.imageView?.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)

        let backgroundView = UIView()
        backgroundView.backgroundColor = self.tableView.separatorColor
        cell.selectedBackgroundView = backgroundView

        cell.textLabel?.highlightedTextColor = UIColor.blackColor()

        if indexPath.section == 0 {
            let action = actions[indexPath.row]
            cell.textLabel?.text = action.title
        } else {
            let formatter = NSDateComponentsFormatter()
            formatter.zeroFormattingBehavior = .Pad
            formatter.allowedUnits = [.Minute, .Second]
            if let time = jumplistItems[indexPath.row].time as? Double {
                cell.textLabel?.text = formatter.stringFromTimeInterval(time)
            } else {
                cell.textLabel?.text = ":O"
            }
        }

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1
            ? "Bookmarks"
            : nil
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            switch actions[indexPath.row].action {
            case .AddJumpListItem:
                performSegueWithIdentifier(segueIdentifier, sender: self)
            }
        } else if let time = jumplistItems[indexPath.row].time as? Double {
            musicPlayer?.play(time)
        }

        deselect()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueIdentifier {
            let pickTimeViewController = segue.destinationViewController as? PickTimeViewController
            pickTimeViewController?.delegate = self
            pickTimeViewController?.duration = musicPlayer?.currentItem?.duration ?? 0

            if let time = musicPlayer?.currentItem?.time {
                pickTimeViewController?.time = time
            }
        }
    }

    func pickTimeDidPickTime(sender: PickTimeViewController, time: Double) {
        dismissViewControllerAnimated(true, completion: nil)

        guard let context = managedObjectContext else {
            return
        }

        guard let mediaItem = musicPlayer?.currentItem?.model else {
            return
        }

        context.performBlock {
            guard let _ = JumplistItem.jumplistItemForMediaItemTime(mediaItem, time: time, context: context) else {
                return
            }

            self.reload()

            guard let _ = try? context.save() else {
                print("Fuck")
                return
            }
        }
    }

    func pickTimeDidCancel(sender: PickTimeViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func deselect() {
        if let selectedPath = tableView?.indexPathForSelectedRow {
            tableView?.deselectRowAtIndexPath(selectedPath, animated: false)
        }
    }

    func reload() {
        if let jumplistSet = musicPlayer?.currentItem?.model?.jumplistItems {
            jumplistItems = Array(jumplistSet)
        } else {
            jumplistItems = []
        }

        dispatch_async(dispatch_get_main_queue()) {
            self.tableView?.reloadData()
        }
    }

}
