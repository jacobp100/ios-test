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

enum DetailViewController: Int {
    case Playlist = 0
    case PitchTempo = 1
}

class ViewController: UIViewController, MPMediaPickerControllerDelegate, PlaySliderDelegate, PitchTempoViewControllerDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var playbackSlider: PlaySlider!

    var displayLink: CADisplayLink?
    var mediaPicker: MPMediaPickerController?
    var audioFile: AVAudioFile? {
        didSet {
            if let playbackAudioFile = audioFile {
                sampleRate = playbackAudioFile.processingFormat.sampleRate
                totalDuration = Double(playbackAudioFile.length) / sampleRate!
            } else {
                sampleRate = nil
                totalDuration = nil
                currentTime = nil
                currentTimeOffset = nil
            }
        }
    }
    var audioEngine = AVAudioEngine()
    var audioPlayerNode = AVAudioPlayerNode()
    var timePitchNode = AVAudioUnitTimePitch()
    var pitch: Int = 0 {
        didSet {
            timePitchNode.pitch = Float(pitch * 100)
        }
    }
    var tempo: Int = 100 {
        didSet {
            timePitchNode.rate = Float(tempo) / 100
        }
    }
    var sampleRate: Double? = nil
    var totalDuration: Double? = nil {
        didSet {
            if let totalDuration = totalDuration {
                playbackSlider.totalDuration = totalDuration
            }
        }
    }
    var currentTimeOffset: Double? = nil
    var currentTime: Double? = nil {
        didSet {
            if let currentTime = currentTime, currentTimeOffset = currentTimeOffset {
                playbackSlider.currentTime = currentTime + currentTimeOffset
            }
        }
    }
    let viewControllerReferences: [DetailViewController:String] = [
        .Playlist: "PlaylistViewController",
        .PitchTempo: "PitchTempoViewController"
    ]

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

        setDetailView(1)

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

    @IBAction func selectedViewChanged(sender: UISegmentedControl) {
        setDetailView(sender.selectedSegmentIndex)
    }

    func setDetailView(index: Int) {
        let storyboardType = DetailViewController(rawValue: index)!
        let reference = viewControllerReferences[storyboardType]!
        let destination = storyboard!.instantiateViewControllerWithIdentifier(reference)

        switch storyboardType {
        case .PitchTempo:
            let pitchTempo = destination as! PitchTempoViewController
            pitchTempo.delegate = self
            pitchTempo.pitch = pitch
            pitchTempo.tempo = tempo
        default:
            break
        }

        destination.view.frame = CGRect(
            x: 0,
            y: 0,
            width: containerView.frame.size.width,
            height: containerView.frame.size.height
        )
        containerView.addSubview(destination.view)
        destination.didMoveToParentViewController(self)
    }

    func pitchTempoPitchChanged(value: Int) {
        pitch = value
    }

    func pitchTempoTempoChanged(value: Int) {
        tempo = value
    }

    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        songLabel.text = mediaItemCollection.items[0].title
    }

    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }

    func playSliderDidTogglePlaying(playSlider: PlaySlider) {
        if audioPlayerNode.playing {
            audioPlayerNode.pause()
        } else if audioEngine.running {
            audioPlayerNode.play()
        } else {
            playFile()
        }
    }

    func playSliderValueDidChange(playSlider: PlaySlider, value: Double) {
        seek(value)
    }

    func playFile() {
        seek(0)
    }

    func seek(time: Double) {
        if !audioEngine.running {
            try! audioEngine.start()
        }

        audioPlayerNode.stop()

        if let playbackSampleRate = sampleRate where time < totalDuration ?? Double.infinity {
            audioPlayerNode.scheduleSegment(
                audioFile!,
                startingFrame: AVAudioFramePosition(playbackSampleRate * time),
                frameCount: AVAudioFrameCount(Double(audioFile!.length) - time * playbackSampleRate),
                atTime: nil,
                completionHandler: nil
            )
            audioPlayerNode.play()

            currentTimeOffset = time
            currentTime = 0

            displayLink!.paused = false
        } else {
            audioPlayerNode.stop()
            audioFile = nil
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

