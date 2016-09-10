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

    let type: String = "LibraryFile"
    var id: String { get { return title } }
    let url: NSURL
    var title: String
    var delegate: MusicPlayerFileDelegate?
    var model: MediaItem?
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

    private var loop: Loop?
    private var audioFile: AVAudioFile?
    private var audioPlayerPlayingSegmentIndex: Int = 0
    private var audioPlayerPlayingSegment = false
    private var audioEngine = AVAudioEngine()
    private var audioPlayerNode = AVAudioPlayerNode()
    private var timePitchNode = AVAudioUnitTimePitch()
    private var seekingTimeOffset: Double? = nil
    private var pauseTime: Double? = nil

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

    func play(time: Double?) {
        audioPlayerPlayingSegmentIndex += 1
        let currentPlayingIndex = audioPlayerPlayingSegmentIndex

        if !audioEngine.running {
            try! audioEngine.start()
        }

        if audioPlayerPlayingSegment {
            audioPlayerNode.stop()
        }

        let currentFile = audioFile!

        var seekTime: Double

        if let timeValue = time {
            seekTime = timeValue
        } else if let pauseTimeValue = pauseTime {
            seekTime = pauseTimeValue
        } else {
            seekTime = 0
        }

        if let currentLoop = loop {
            if seekTime >= currentLoop.end {
                delegate?.musicPlayerFileDidCompleteLoop(self)
                seekTime = currentLoop.start
            } else {
                seekTime = max(seekTime, currentLoop.start)
            }
        }

        pauseTime = nil
        seekingTimeOffset = seekTime

        let startingFrame = currentFile.sampleRate * seekTime

        var endingFrame: Double
        if let currentLoop = loop {
            endingFrame = currentFile.sampleRate * currentLoop.end
        } else {
            endingFrame = currentFile.frames
        }

        guard startingFrame < endingFrame else {
            delegate?.musicPlayerFileDidFinish(self)
            return
        }

        audioPlayerPlayingSegment = true // Combine with playing?
        audioPlayerNode.scheduleSegment(
            currentFile,
            startingFrame: AVAudioFramePosition(startingFrame),
            frameCount: AVAudioFrameCount(endingFrame - startingFrame),
            atTime: nil,
            completionHandler: {
                [weak weakSelf = self] () -> Void in
                guard let this = weakSelf where this.audioPlayerPlayingSegmentIndex == currentPlayingIndex else {
                    return
                }

                this.audioPlayerPlayingSegment = false

                if this.loop != nil {
                    this.play(nil)
                    this.delegate?.musicPlayerFileDidCompleteLoop(this)
                } else {
                    this.audioEngine.stop()
                    this.seekingTimeOffset = this.duration
                    this.delegate?.musicPlayerFileDidFinish(this)
                }
            }
        )
        audioPlayerNode.play()
    }

    func pause() {
        pauseTime = time
        seekingTimeOffset = time
        stopPause()
    }

    func stop() {
        pauseTime = nil
        stopPause()
    }

    func loop(loop: Loop) {
        stop()
        self.loop = loop
        play(nil)
    }

    private func stopPause() {
        audioPlayerPlayingSegmentIndex += 1
        audioEngine.stop()
        if audioPlayerPlayingSegment {
            audioPlayerNode.stop()
        }
    }
}
