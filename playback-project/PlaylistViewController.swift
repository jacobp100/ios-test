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

    var playlist: [String] = [] { didSet { tableView?.reloadData() } }
    var delegate: PlaylistViewControllerDelegate?

    private let actionTitles = [
        "Add from Library",
        "Clear Playlist"
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

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? actionTitles.count : playlist.count
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
            cell.imageView?.image = indexPath.row == 0
                ? UIImage(named: "tableview-add")
                : UIImage(named: "tableview-clear")
        } else {
            cell.textLabel?.text = playlist[indexPath.row]
            cell.imageView?.image = indexPath.row == 2
                ? UIImage(named: "tableview-speaker")
                : UIImage(named: "tableview-blank")
        }

        return cell
    }

}
