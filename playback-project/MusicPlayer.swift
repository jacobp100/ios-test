//
//  MusicPlayer.swift
//  playback-project
//
//  Created by Jacob Parker on 02/06/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

@objc class MusicItem: NSObject {
    var title: String!
    var url: NSURL!

    init(title: String, url: NSURL) {
        self.title = title
        self.url = url
    }
}

class MusicFile {
    var url: NSURL!
    var file: AVAudioFile!

    init(url: NSURL, file: AVAudioFile) {
        self.url = url
        self.file = file
    }
}

class MusicPlayer: NSObject {

    dynamic var playlist: [MusicItem] = []
    private(set) dynamic var currentItem: MusicItem?
    dynamic var pitch: Int = 0 {
        didSet {
            timePitchNode.pitch = Float(pitch * 100)
        }
    }
    dynamic var tempo: Int = 100 {
        didSet {
            timePitchNode.rate = Float(tempo) / 100
        }
    }
    var totalDuration: Double? = nil
    var currentTime: Double {
        get {
            var time = currentTimeOffset ?? 0

            if let lastRenderTime = audioPlayerNode.lastRenderTime,
                let currentAudioTime = audioPlayerNode.playerTimeForNodeTime(lastRenderTime),
                let playbackSampleRate = sampleRate {
                time += Double(currentAudioTime.sampleTime) / playbackSampleRate
            }

            return time
        }
    }

    private var sampleRate: Double? = nil
    private var audioEngine = AVAudioEngine()
    private var audioPlayerNode = AVAudioPlayerNode()
    private var timePitchNode = AVAudioUnitTimePitch()
    private var currentFile: MusicFile?
    private var currentTimeOffset: Double? = nil

    override init() {
        super.init()

        audioEngine.attachNode(audioPlayerNode)
        audioEngine.attachNode(timePitchNode)

        audioEngine.connect(audioPlayerNode, to: timePitchNode, format: nil)
        audioEngine.connect(timePitchNode, to: audioEngine.outputNode, format: nil)
    }

    func addFiles(files: [MusicItem]) {
        playlist.appendContentsOf(files)
        seek(0)
    }

    func play() {
        if currentItem == nil {
            currentItem = playlist.first
        }

        seek(0)
    }

    func seek(time: Double) {
        if !audioEngine.running {
            try! audioEngine.start()
        }

        audioPlayerNode.stop()

        var audioFile: AVAudioFile? = nil

        if let playbackCurrentItem = currentItem {
            if let playbackCurrentFile = currentFile where playbackCurrentFile.url == playbackCurrentItem.url {
                audioFile = playbackCurrentFile.file
            } else if let newAudioFile = try? AVAudioFile(forReading: playbackCurrentItem.url) {
                audioFile = newAudioFile
                currentFile = MusicFile(
                    url: playbackCurrentItem.url,
                    file: newAudioFile
                )
            }
        }

        if let playbackAudioFile = audioFile where time < totalDuration ?? Double.infinity {
            sampleRate = playbackAudioFile.processingFormat.sampleRate
            totalDuration = Double(playbackAudioFile.length) / sampleRate!
            currentTimeOffset = time

            let startingFrame = sampleRate! * time
            let endingFrame = Double(playbackAudioFile.length)

            audioPlayerNode.scheduleSegment(
                playbackAudioFile,
                startingFrame: AVAudioFramePosition(startingFrame),
                frameCount: AVAudioFrameCount(endingFrame - startingFrame),
                atTime: nil,
                completionHandler: nil
            )
            audioPlayerNode.play()
        } else {
            currentItem = nil
            sampleRate = nil
            totalDuration = nil
            currentTimeOffset = nil
        }
    }

}
