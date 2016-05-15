//
//  ViewController.swift
//  playback-project
//
//  Created by Jacob Parker on 14/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class ViewController: UIViewController, MPMediaPickerControllerDelegate {

    @IBOutlet weak var songLabel: UILabel!
    var mediaPicker: MPMediaPickerController?
    var audioFile: AVAudioFile?
    var audioEngine: AVAudioEngine?
    var audioPlayerNode: AVAudioPlayerNode?
    var timePitchNode: AVAudioUnitTimePitch?
    var pitch: Int = 1 {
        didSet {
            timePitchNode!.pitch = Float(pitch * 100)
        }
    }
    var tempo: Float = 100 {
        didSet {
            timePitchNode!.rate = Float(tempo / 100)
        }
    }
    var currentTime = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()

        let bundle = NSBundle.mainBundle()
        let demoFile = bundle.URLForResource("starwars", withExtension: "mp3")!

        audioFile = try? AVAudioFile(forReading: demoFile)

        audioEngine = AVAudioEngine()

        audioPlayerNode = AVAudioPlayerNode()
        audioEngine!.attachNode(audioPlayerNode!)

        timePitchNode = AVAudioUnitTimePitch()
        audioEngine!.attachNode(timePitchNode!)

        audioEngine!.connect(audioPlayerNode!, to: timePitchNode!, format: nil)
        audioEngine!.connect(timePitchNode!, to: audioEngine!.outputNode, format: nil)

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addSongButtonPressed(sender: UIButton) {
        mediaPicker = MPMediaPickerController(mediaTypes: .AnyAudio)

        if let picker = mediaPicker {
            picker.delegate = self
            view.addSubview(picker.view)

            presentViewController(picker, animated: true, completion: nil)
        }
    }

    @IBAction func playButtonPressed(sender: UIButton) {
        play()
    }

    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        songLabel.text = mediaItemCollection.items[0].title
    }

    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }

    func play() {
        audioPlayerNode!.stop()
        audioEngine!.stop()
        audioEngine!.reset()

        try! audioEngine!.start()

        audioPlayerNode!.scheduleFile(audioFile!, atTime: nil, completionHandler: nil)
        audioPlayerNode!.play()
    }

}

