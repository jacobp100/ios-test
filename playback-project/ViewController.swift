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

class ViewController: UIViewController, MPMediaPickerControllerDelegate, PlaySliderDelegate {

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
    var sampleRate: Double? = nil
    var totalDuration: Double? = nil {
        didSet {
            if let totalDuration = totalDuration {
                playbackSlider.maximum = totalDuration
            }
        }
    }
    var currentTimeOffset: Double? = nil
    var currentTime: Double? = nil {
        didSet {
            if let currentTime = currentTime, currentTimeOffset = currentTimeOffset {
                playbackSlider.value = currentTime + currentTimeOffset
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        playbackSlider.delegate = self

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

        tempoSlider.maximum = 100000
        tempoSlider.step = 10000
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

    @IBAction func pitchSliderChanged(sender: SliderView) {
        pitch = sender.value
    }

    @IBAction func tempoSliderChanged(sender: SliderView) {
        tempo = sender.value
    }

    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        songLabel.text = mediaItemCollection.items[0].title
    }

    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }

    func playSliderDidTogglePlaying() {
        if audioPlayerNode.playing {
            audioPlayerNode.pause()
        } else if audioEngine.running {
            audioPlayerNode.play()
        } else {
            playFile()
        }
    }

    func playSliderValueDidChange(value: Double) {
        seek(value)
    }

    func playFile() {
        if !audioEngine.running {
            try! audioEngine.start()
        }

        seek(0)
    }

    func seek(time: Double) {
        audioPlayerNode.stop()

        let playbackSampleRate = sampleRate ?? 0

        if time < totalDuration ?? Double.infinity || playbackSampleRate == 0 {
            audioPlayerNode.scheduleSegment(
                audioFile!,
                startingFrame: AVAudioFramePosition(playbackSampleRate * time),
                frameCount: AVAudioFrameCount(Double(audioFile!.length) - time * playbackSampleRate),
                atTime: nil,
                completionHandler: nil
            )
            audioPlayerNode.play()

            let zeroAudioTime = audioPlayerNode.playerTimeForNodeTime(audioPlayerNode.lastRenderTime!)!
            sampleRate = zeroAudioTime.sampleRate
            currentTimeOffset = time
            currentTime = 0
            totalDuration = (time + Double(audioFile!.length)) / sampleRate!

            displayLink!.paused = false
        } else {
            audioPlayerNode.stop()
            sampleRate = nil
            currentTimeOffset = nil
            currentTime = nil
            totalDuration = nil
        }
    }

    func handler() {
        print(time)
    }

    func updateTime() {
        if let lastRenderTime = audioPlayerNode.lastRenderTime,
            let currentAudioTime = audioPlayerNode.playerTimeForNodeTime(lastRenderTime) {
            currentTime = Double(currentAudioTime.sampleTime) / currentAudioTime.sampleRate
        }
    }

}

