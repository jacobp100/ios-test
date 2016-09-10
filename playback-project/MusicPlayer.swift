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
import CoreData

protocol MusicPlayerFileDelegate {
    func musicPlayerFileDidLoad(sender: MusicPlayerFile)
    func musicPlayerFileDidError(sender: MusicPlayerFile)
    func musicPlayerFileDidFinish(sender: MusicPlayerFile)
    func musicPlayerFileDidCompleteLoop(sender: MusicPlayerFile)
}

protocol MusicPlayerFile: class {
    var type: String { get }
    var id: String { get }
    var delegate: MusicPlayerFileDelegate? { get set }
    var model: MediaItem? { get set }
    var title: String { get }
    var duration: Double? { get }
    var time: Double { get }
    var loaded: Bool { get }
    var pitch: Float { get set }
    var tempo: Float { get set }
    func enque()
    func play(time: Double?)
    func pause()
    func stop()
    func loop(loop: Loop)
}

struct Loop {
    var start: Double
    var end: Double
}

class MusicPlayer: NSObject, MusicPlayerFileDelegate {

    static let PLAYLIST_DID_CHANGE = "MUSIC_PLAYER_PLAYLIST_DID_CHANGE"
    static let ITEM_DID_CHANGE = "MUSIC_PLAYER_ITEM_DID_CHANGE"
    static let ITEM_DID_LOAD = "MUSIC_PLAYER_ITEM_DID_LOAD"
    static let PITCH_DID_CHANGE = "MUSIC_PLAYER_PITCH_DID_CHANGE"
    static let TEMPO_DID_CHANGE = "MUSIC_PLAYER_TEMPO_DID_CHANGE"
    static let LOOP_DID_CHANGE = "MUSIC_PLAYER_LOOP_DID_CHANGE"

    var playlist: [MusicPlayerFile] = [] {
        didSet {
            emitEvent(MusicPlayer.PLAYLIST_DID_CHANGE)
            updatePlaylist()
        }
    }
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
    var loop: Loop? = nil

    var currentItem: MusicPlayerFile? {
        get {
            return currentIndex < playlist.count && currentIndex >= 0
                ? playlist[currentIndex]
                : nil
        }
    }

    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext // FIXME

    private enum SeekItemAction {
        case Play
        case Loop
    }
    private struct SeekItem {
        var item: MusicPlayerFile
        var action: SeekItemAction
        var time: Double?
        var loop: Loop?
    }
    private var seekItem: SeekItem?

    override init() {
        super.init()
    }

    func addFiles(files: [MusicPlayerFile]) {
        let enqueFirst = playlist.isEmpty

        playlist += files

        if let item = playlist.first where item.delegate as? MusicPlayer !== self && enqueFirst {
            loadItem(item)
            item.enque()
        }
    }

    func clearFiles() {
        playlist = []
    }

    func playAtIndex(index: Int) {
        stop()

        if index < playlist.count {
            currentIndex = index
            play()
        }
    }

    func play() {
        play(nil)
    }

    func play(time: Double?) {
        if currentIndex < 0 {
            currentIndex = 0
        }

        guard let item = currentItem else {
            return
        }

        if item.loaded {
            seekItem = nil
            item.play(time)
            playing = true
            return
        }

        seekItem = SeekItem(item: item, action: .Play, time: time, loop: nil)

        if item.delegate as? MusicPlayer !== self {
            loadItem(item)
            item.enque()
        }
    }

    func loop(loop: Loop) {
        if currentIndex < 0 {
            currentIndex = 0
        }

        guard let item = currentItem else {
            return
        }

        if item.loaded {
            seekItem = nil
            item.loop(loop)
            playing = true
            return
        }

        seekItem = SeekItem(item: item, action: .Loop, time: nil, loop: loop)

        if item.delegate as? MusicPlayer !== self {
            loadItem(item)
            item.enque()
        }
    }

    func stop() {
        if let item = currentItem {
            item.stop()
        }

        playing = false
    }

    func pause() {
        if let item = currentItem {
            item.pause()
        }

        playing = false
    }

    private func loadItem(item: MusicPlayerFile) {
        item.delegate = self

        if let context = managedObjectContext {
            item.model = MediaItem.mediaItemForMusicPlayerFile(item, context: context)
        }
    }

    private func playNext() {
        if currentIndex < playlist.count - 1 {
            currentIndex += 1
            play(0)
        } else {
            stop()
        }
    }

    func musicPlayerFileDidLoad(sender: MusicPlayerFile) {
        guard let currentSeekItem = seekItem where currentSeekItem.item === sender else {
            return
        }

        switch currentSeekItem.action {
        case .Play:
            play(currentSeekItem.time)
        case .Loop:
            loop(currentSeekItem.loop!)
        }

        emitEvent(MusicPlayer.ITEM_DID_LOAD)
    }

    func musicPlayerFileDidError(sender: MusicPlayerFile) {
        print("Oh no")
    }

    func musicPlayerFileDidFinish(sender: MusicPlayerFile) {
        playNext()
    }

    func musicPlayerFileDidCompleteLoop(sender: MusicPlayerFile) {
        // okay
    }

    private func updatePlaylist() {
        guard let context = managedObjectContext else {
            return
        }

        let mediaItemSetOptional = playlist.reduce(NSMutableOrderedSet()) {
            (setOptional: NSMutableOrderedSet?, musicPlayerFile: MusicPlayerFile) -> NSMutableOrderedSet? in
            if let set = setOptional, let mediaItem = MediaItem.mediaItemForMusicPlayerFile(musicPlayerFile, context: context) {
                set.addObject(mediaItem)
                return set
            }
            return nil
        }

        guard let mediaItemSet = mediaItemSetOptional else {
            return
        }

        context.performBlock {
            if let playlist = Playlist.playlistForName("Current Playlist", context: context) {
                playlist.mediaItems = mediaItemSet
            }

            guard let _ = try? context.save() else {
                print("Fuck")
                return
            }
        }
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
