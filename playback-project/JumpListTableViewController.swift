//
//  JumpListTableViewController.swift
//  playback-project
//
//  Created by Jacob Parker on 03/06/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit


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

    var musicPlayer: MusicPlayer?

    private var actions: [JumpListAction] = [
        JumpListAction(title: "Bookmark Current Time", action: .AddJumpListItem)
    ]
    private var segueIdentifier = "CurrentTimeSelection"

    override func viewDidLoad() {
        super.viewDidLoad()
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
            : 5
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
            cell.textLabel?.text = ":D"
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
                deselect()
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueIdentifier {
            let pickTimeViewController = segue.destinationViewController as? PickTimeViewController
            pickTimeViewController?.delegate = self
            print(musicPlayer?.totalDuration)
            pickTimeViewController?.duration = musicPlayer?.totalDuration ?? 0
        }
    }

    func pickTimeDidPickTime(sender: PickTimeViewController, time: Double) {
        print(time)
        dismissViewControllerAnimated(true, completion: nil)
    }

    func pickTimeDidCancel(sender: PickTimeViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func deselect() {
        if let selectedPath = tableView?.indexPathForSelectedRow {
            tableView?.deselectRowAtIndexPath(selectedPath, animated: false)
        }
    }

}
