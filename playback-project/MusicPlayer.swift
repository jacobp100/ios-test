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

extension AVAudioFile {
    var sampleRate: Double { get { return processingFormat.sampleRate } }
    var frames: Double { get { return Double(length) } }
    var duration: Double { get { return frames / sampleRate } }
}

class MusicPlayer: NSObject {

    dynamic var playlist: [MusicItem] = []
    dynamic var currentIndex: Int = -1
    dynamic var playing: Bool = false
    dynamic var pitch: Int = 0 { didSet { timePitchNode.pitch = Float(pitch * 100) } }
    dynamic var tempo: Int = 100 { didSet { timePitchNode.rate = Float(tempo) / 100 } }

    var currentItem: MusicItem? {
        get {
            return currentIndex < playlist.count && currentIndex >= 0
                ? playlist[currentIndex]
                : nil
        }
    }
    var totalDuration: Double? {
        get {
            if let playbackCurrentFile = getCurrentFile() {
                return playbackCurrentFile.duration
            }
            return nil
        }
    }
    var currentTime: Double {
        get {
            return
                (seekingTimeOffset ?? 0) +
                (encueNextTimeOffset ?? 0) +
                getLastRenderTime()
        }
    }

    private var audioPlayerPlayingSegmentIndex: Int = 0
    private var audioPlayerPlayingSegment: Bool = false
    private var audioEngine = AVAudioEngine()
    private var audioPlayerNode = AVAudioPlayerNode()
    private var timePitchNode = AVAudioUnitTimePitch()
    private var playlistCache: [NSURL:AVAudioFile] = [:]
    private var seekingTimeOffset: Double? = nil
    private var encueNextTimeOffset: Double? = nil

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

    func clearFiles() {
        playlist.removeAll(keepCapacity: false)
        playlistCache.removeAll(keepCapacity: false)
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

    func stop() {
        seekingTimeOffset = getCurrentFile()?.duration
        audioEngine.stop()

        if audioPlayerPlayingSegment {
            audioPlayerNode.stop()
        }

        currentIndex = -1
        seekingTimeOffset = nil
        encueNextTimeOffset = nil
        playing = false
    }

    func seek(time: Double) {
        audioPlayerPlayingSegmentIndex += 1
        let currentPlayingIndex = audioPlayerPlayingSegmentIndex

        if !audioEngine.running {
            try! audioEngine.start()
        }

        if audioPlayerPlayingSegment {
            audioPlayerNode.stop()
            encueNextTimeOffset = 0
        }

        if currentIndex < 0 {
            currentIndex = 0
        }

        if let audioFile = getCurrentFile() where time < audioFile.duration {
            seekingTimeOffset = time

            let startingFrame = audioFile.sampleRate * time

            audioPlayerNode.scheduleSegment(
                audioFile,
                startingFrame: AVAudioFramePosition(startingFrame),
                frameCount: AVAudioFrameCount(audioFile.frames - startingFrame),
                atTime: nil,
                completionHandler: {
                    [weak this = self] () -> Void in
                    guard currentPlayingIndex == this?.audioPlayerPlayingSegmentIndex else {
                        return
                    }

                    this?.audioPlayerPlayingSegment = false
                    this?.encueNextTimeOffset = -(this?.getLastRenderTime() ?? 0)
                    this?.playNext()
                }
            )
            audioPlayerNode.play()
            playing = true
            audioPlayerPlayingSegment = true // Combine with playing?
        } else {
            playNext()
        }
    }

    private func playNext() {
        if currentIndex < playlist.count - 1 {
            currentIndex += 1
            seek(0)
        } else {
            stop()
        }
    }

    private func getLastRenderTime() -> Double {
        if let playbackFile = getCurrentFile(),
            let lastRenderTime = audioPlayerNode.lastRenderTime,
            let currentAudioTime = audioPlayerNode.playerTimeForNodeTime(lastRenderTime) {
            return Double(currentAudioTime.sampleTime) / playbackFile.sampleRate
        }
        return 0
    }

    private func getCurrentFile() -> AVAudioFile? {
        guard let currentUrl = currentItem?.url else {
            return nil
        }

        if let cachedFile = playlistCache[currentUrl] {
            return cachedFile
        } else if let audioFile = try? AVAudioFile(forReading: currentUrl) {
            playlistCache[currentUrl] = audioFile
            return audioFile
        } else {
            return nil
        }
    }

}
