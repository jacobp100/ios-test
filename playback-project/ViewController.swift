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
    @IBOutlet weak var playbackSlider: PlaySlider!
    @IBOutlet weak var pitchSlider: SliderView!
    @IBOutlet weak var tempoSlider: SliderView!

    var displayLink: CADisplayLink?
    var mediaPicker: MPMediaPickerController?
    var audioFile: AVAudioFile?
    var audioEngine = AVAudioEngine()
    var audioPlayerNode = AVAudioPlayerNode()
    var timePitchNode = AVAudioUnitTimePitch()
    var pitch: Int = 0 {
        didSet {
            timePitchNode.pitch = Float(pitch * 100)
            pitchSlider.text = pitch >= 0
                ? "+\(pitch)"
                : "\(pitch)"
        }
    }
    var tempo: Int = 100 {
        didSet {
            timePitchNode.rate = Float(tempo) / 100
            tempoSlider.text = "\(tempo)%"
        }
    }
    var totalDuration: Double = 0 {
        didSet {
            playbackSlider.maximum = totalDuration
        }
    }
    var currentTime: Double = 0 {
        didSet {
            playbackSlider.value = currentTime
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        displayLink = CADisplayLink(target: self, selector: #selector(ViewController.updateTime))
        displayLink!.paused = true
        displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)

        let bundle = NSBundle.mainBundle()
        let demoFile = bundle.URLForResource("starwars", withExtension: "mp3")!

        audioFile = try? AVAudioFile(forReading: demoFile)

        audioEngine = AVAudioEngine()

        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)

        timePitchNode = AVAudioUnitTimePitch()
        audioEngine.attachNode(timePitchNode)

        audioEngine.connect(audioPlayerNode, to: timePitchNode, format: nil)
        audioEngine.connect(timePitchNode, to: audioEngine.outputNode, format: nil)

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

    @IBAction func pitchSliderChanged(sender: SliderView) {
        pitch = sender.value
    }

    @IBAction func tempoSliderChanged(sender: SliderView) {
        tempo = sender.value
//        let playerTime = audioPlayerNode.playerTimeForNodeTime(audioPlayerNode.lastRenderTime!)
//        let totalTime = audioFile?.length;
//        print(Double(playerTime!.sampleTime) / playerTime!.sampleRate)
//        print(Double(totalTime!) / playerTime!.sampleRate)
    }

    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        songLabel.text = mediaItemCollection.items[0].title
    }

    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }

    func play() {
        audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.reset()

        try! audioEngine.start()

        audioPlayerNode.scheduleFile(audioFile!, atTime: nil, completionHandler: nil)
        audioPlayerNode.play()

        let zeroAudioTime = audioPlayerNode.playerTimeForNodeTime(audioPlayerNode.lastRenderTime!)
        currentTime = 0
        totalDuration = Double(audioFile!.length) / zeroAudioTime!.sampleRate

        displayLink!.paused = false
    }

    func updateTime() {
        let currentAudioTime = audioPlayerNode.playerTimeForNodeTime(audioPlayerNode.lastRenderTime!)
        currentTime = Double(currentAudioTime!.sampleTime) / currentAudioTime!.sampleRate
    }

}

