//
//  MusicPlayerAudioFile.swift
//  playback-project
//
//  Created by Jacob Parker on 04/06/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation


extension AVAudioFile {
    var sampleRate: Double { get { return processingFormat.sampleRate } }
    var frames: Double { get { return Double(length) } }
    var duration: Double { get { return frames / sampleRate } }
}


class MusicPlayerAudioFile: NSObject, MusicPlayerFile {

    var url: NSURL
    var title: String
    var delegate: MusicPlayerFileDelegate?
    var loaded: Bool { get { return audioFile != nil } }
    var duration: Double? { get { return audioFile?.duration } }
    var time: Double {
        get {
            var time = seekingTimeOffset ?? 0

            if let currentFile = audioFile,
                let lastRenderTime = audioPlayerNode.lastRenderTime,
                let currentAudioTime = audioPlayerNode.playerTimeForNodeTime(lastRenderTime) {
                time += Double(currentAudioTime.sampleTime) / currentFile.sampleRate
            }

            return time
        }
    }
    var pitch: Float = 0 { didSet { timePitchNode.pitch = pitch } }
    var tempo: Float = 1 { didSet { timePitchNode.rate = tempo } }

    private var audioFile: AVAudioFile?
    private var audioPlayerPlayingSegmentIndex: Int = 0
    private var audioPlayerPlayingSegment = false
    private var audioEngine = AVAudioEngine()
    private var audioPlayerNode = AVAudioPlayerNode()
    private var timePitchNode = AVAudioUnitTimePitch()
    private var seekingTimeOffset: Double? = nil

    init(title: String, url: NSURL) {
        self.title = title
        self.url = url

        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(timePitchNode)

        audioEngine.connect(audioPlayerNode, to: timePitchNode, format: nil)
        audioEngine.connect(timePitchNode, to: audioEngine.outputNode, format: nil)
    }

    func enque() {
        if audioFile != nil {
            delegate?.musicPlayerFileDidLoad(self)
        } else if let newAudioFile = try? AVAudioFile(forReading: url) {
            audioFile = newAudioFile
            delegate?.musicPlayerFileDidLoad(self)
        } else {
            delegate?.musicPlayerFileDidError(self)
        }
    }

    func seek(time: Double) {
        audioPlayerPlayingSegmentIndex += 1
        let currentPlayingIndex = audioPlayerPlayingSegmentIndex

        if !audioEngine.running {
            try! audioEngine.start()
        }

        if audioPlayerPlayingSegment {
            audioPlayerNode.stop()
        }

        let currentFile = audioFile!

        if time < currentFile.duration {
            seekingTimeOffset = time

            let startingFrame = currentFile.sampleRate * time

            audioPlayerNode.scheduleSegment(
                currentFile,
                startingFrame: AVAudioFramePosition(startingFrame),
                frameCount: AVAudioFrameCount(currentFile.frames - startingFrame),
                atTime: nil,
                completionHandler: {
                    [weak weakSelf = self] () -> Void in
                    if let this = weakSelf where this.audioPlayerPlayingSegmentIndex == currentPlayingIndex {
                        this.seekingTimeOffset = this.duration
                        this.audioPlayerPlayingSegment = false
                        this.audioEngine.stop()
                        this.delegate?.musicPlayerFileDidFinish(this)
                    }
                }
            )
            audioPlayerNode.play()
            audioPlayerPlayingSegment = true // Combine with playing?
        } else {
            delegate?.musicPlayerFileDidFinish(self)
        }
    }

    func stop() {
        audioEngine.stop()
        if audioPlayerPlayingSegment {
            audioPlayerNode.stop()
        }
    }
}
