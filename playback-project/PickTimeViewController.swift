//
//  PickTimeViewController.swift
//  playback-project
//
//  Created by Jacob Parker on 03/06/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit
import Foundation

protocol PickTimeDelegate {
    func pickTimeDidPickTime(sender: PickTimeViewController, time: Double)
    func pickTimeDidCancel(sender: PickTimeViewController)
}

class PickTimeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var picker: UIPickerView?

    var duration: Double = 60 { didSet { picker?.reloadAllComponents() } }
    var delegate: PickTimeDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        picker!.delegate = self
        picker!.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func confirm(sender: AnyObject) {
        let minutes = picker!.selectedRowInComponent(0)
        let seconds = picker!.selectedRowInComponent(1)
        let selectedDuration = Double(minutes * 60 + seconds)
        let time = min(selectedDuration, duration)
        delegate?.pickTimeDidPickTime(self, time: time)
    }

    @IBAction func cancel(sender: AnyObject) {
        delegate?.pickTimeDidCancel(self)
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return Int(floor(duration / 60)) + 1
        } else if duration < 60 {
            return Int(ceil(duration % 60)) + 1
        } else {
            return 60
        }
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(row)
        } else {
            return String(format: "%02d", row)
        }
    }

}
