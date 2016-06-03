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
    var sampleRate: Double!
    var frames: Double!
    var duration: Double!

    init(url: NSURL, file: AVAudioFile) {
        self.url = url
        self.file = file
        self.sampleRate = file.processingFormat.sampleRate
        self.frames = Double(file.length)
        self.duration = Double(frames) / sampleRate
    }
}

class MusicPlayer: NSObject {

    dynamic var playlist: [MusicItem] = []
    dynamic var currentIndex: Int = -1
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
    var currentItem: MusicItem? {
        get {
            return currentIndex < playlist.count && currentIndex >= 0
                ? playlist[currentIndex]
                : nil
        }
    }
    var totalDuration: Double? {
        get {
            if let playbackCurrentFile = currentFile {
                return playbackCurrentFile.duration
            }
            return nil
        }
    }
    var currentTime: Double {
        get {
            var time = currentTimeOffset ?? 0

            if let lastRenderTime = audioPlayerNode.lastRenderTime,
                let currentAudioTime = audioPlayerNode.playerTimeForNodeTime(lastRenderTime),
                let playbackFile = currentFile {
                time += Double(currentAudioTime.sampleTime) / playbackFile.sampleRate
            }

            return time
        }
    }

    private var audioEngine = AVAudioEngine()
    private var audioPlayerNode = AVAudioPlayerNode()
    private var timePitchNode = AVAudioUnitTimePitch()
    private var currentFile: MusicFile? {
        get {
            if currentIndex < 0 || currentIndex >= playlist.count {
                return nil
            }

            let currentUrl = playlist[currentIndex].url

            if let cachedFile = playlistCache[currentUrl] {
                return cachedFile
            } else if let newAudioFile = try? AVAudioFile(forReading: currentUrl) {
                let musicFile = MusicFile(
                    url: currentUrl,
                    file: newAudioFile
                )
                playlistCache[currentUrl] = musicFile
                return musicFile
            } else {
                return nil
            }
        }
    }
    private var playlistCache: [NSURL:MusicFile] = [:]
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
    }

    func playAtIndex(index: Int) {
        if index < playlist.count {
            currentIndex = index
            seek(0)
        }
    }

    func play() {
        seek(0)
    }

    func seek(time: Double) {
        if !audioEngine.running {
            try! audioEngine.start()
        }

        if currentIndex < 0 {
            currentIndex = 0
        }

        audioPlayerNode.stop()

        if let playbackMusicFile = currentFile where time < playbackMusicFile.duration {
            currentTimeOffset = time

            let startingFrame = playbackMusicFile.sampleRate * time

            audioPlayerNode.scheduleSegment(
                playbackMusicFile.file,
                startingFrame: AVAudioFramePosition(startingFrame),
                frameCount: AVAudioFrameCount(playbackMusicFile.frames - startingFrame),
                atTime: nil,
                completionHandler: nil
            )
            audioPlayerNode.play()
        } else {
            currentIndex = -1
            currentTimeOffset = nil
        }
    }

}
