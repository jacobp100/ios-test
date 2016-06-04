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

protocol MusicPlayerFileDelegate {
    func musicPlayerFileDidLoad(sender: MusicPlayerFile)
    func musicPlayerFileDidError(sender: MusicPlayerFile)
    func musicPlayerFileDidFinish(sender: MusicPlayerFile)
}

protocol MusicPlayerFile: class {
    var delegate: MusicPlayerFileDelegate? { get set }
    var title: String { get }
    var duration: Double? { get }
    var time: Double { get }
    var loaded: Bool { get }
    var pitch: Float { get set }
    var tempo: Float { get set }
    func enque()
    func seek(time: Double)
    func stop()
}

class MusicPlayer: NSObject, MusicPlayerFileDelegate {

    static let PLAYLIST_DID_CHANGE = "PLAYLIST_DID_CHANGE"
    static let ITEM_DID_CHANGE = "ITEM_DID_CHANGE"
    static let ITEM_DID_LOAD = "ITEM_DID_LOAD"
    static let PITCH_DID_CHANGE = "PITCH_DID_CHANGE"
    static let TEMPO_DID_CHANGE = "TEMPO_DID_CHANGE"

    var playlist: [MusicPlayerFile] = [] { didSet { emitEvent(MusicPlayer.PLAYLIST_DID_CHANGE) } }
    var currentIndex: Int = -1 { didSet { emitEvent(MusicPlayer.ITEM_DID_CHANGE) } }
    var playing: Bool = false
    var pitch: Int = 0 {
        didSet {
            emitEvent(MusicPlayer.PITCH_DID_CHANGE)
            currentItem?.pitch = realPitchForPitch(pitch)
        }
    }
    var tempo: Int = 100 {
        didSet {
            emitEvent(MusicPlayer.TEMPO_DID_CHANGE)
            currentItem?.tempo = realTempoForTempo(tempo)
        }
    }

    var currentItem: MusicPlayerFile? {
        get {
            return currentIndex < playlist.count && currentIndex >= 0
                ? playlist[currentIndex]
                : nil
        }
    }

    private struct SeekItem {
        var item: MusicPlayerFile
        var time: Double
    }
    private var seekItem: SeekItem?

    override init() {
        super.init()
    }

    func addFiles(files: [MusicPlayerFile]) {
        let enqueFirst = playlist.isEmpty

        playlist += files

        if let firstItem = playlist.first where enqueFirst {
            firstItem.delegate = self
            firstItem.enque()
        }
    }

    func clearFiles() {
        playlist = []
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
        playing = false
    }

    func seek(time: Double) {
        if currentIndex < 0 {
            currentIndex = 0
        }

        guard let item = currentItem else {
            return
        }

        if item.loaded {
            seekItem = nil
            item.seek(time)
            return
        }

        seekItem = SeekItem(item: item, time: time)

        if item.delegate as? MusicPlayer !== self {
            item.delegate = self
            item.enque()
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

    func musicPlayerFileDidLoad(sender: MusicPlayerFile) {
        if let currentSeekItem = seekItem where currentSeekItem.item === sender {
            emitEvent(MusicPlayer.ITEM_DID_LOAD)
            seek(currentSeekItem.time)
        }
    }

    func musicPlayerFileDidError(sender: MusicPlayerFile) {
        print("Oh no")
    }

    func musicPlayerFileDidFinish(sender: MusicPlayerFile) {
        playNext()
    }

    private func realPitchForPitch(pitch: Int) -> Float {
        return Float(pitch * 100)
    }

    private func realTempoForTempo(tempo: Int) -> Float {
        return Float(tempo) / 100
    }

    private func emitEvent(name: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(
            name,
            object: self
        )
    }

}
