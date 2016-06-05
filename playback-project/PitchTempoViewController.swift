//
//  PitchTempoViewController.swift
//  playback-project
//
//  Created by Jacob Parker on 30/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit

class PitchTempoViewController: UIViewController, SliderViewDelegate {

    @IBOutlet weak var pitchSlider: SliderView?
    @IBOutlet weak var tempoSlider: SliderView?

    var musicPlayer: MusicPlayer? {
        didSet {
            setProperties()

            if oldValue != nil {
                removeEvents()
            }

            if let currentMusicPlayer = musicPlayer {
                addEventListeners(
                    selector: #selector(PitchTempoViewController.setProperties),
                    events: [MusicPlayer.PITCH_DID_CHANGE, MusicPlayer.TEMPO_DID_CHANGE],
                    object: currentMusicPlayer
                )
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pitchSlider!.delegate = self
        tempoSlider!.delegate = self
        setProperties()
    }

    deinit {
        removeEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setProperties() {
        setPitchSliderProperties()
        setTempoSliderProperties()
    }

    func sliderViewDidChangeValue(slider: SliderView) {
        switch (slider) {
        case pitchSlider!:
            musicPlayer?.pitch = pitchSlider!.value
        case tempoSlider!:
            musicPlayer?.tempo = tempoSlider!.value
        default:
            break
        }
    }

    func sliderViewDidTap(slider: SliderView) {
    }

    func setPitchSliderProperties() {
        if let pitch = musicPlayer?.pitch {
            let pitchFormatter = NSNumberFormatter()
            pitchFormatter.positivePrefix = "+"
            pitchSlider?.text = pitchFormatter.stringFromNumber(pitch)!
        } else {
            pitchSlider?.text = "?"
        }

        pitchSlider?.value = musicPlayer?.pitch ?? 0
    }

    func setTempoSliderProperties() {
        if let tempo = musicPlayer?.tempo {
            tempoSlider?.text = "\(tempo)%"
        } else {
            tempoSlider?.text = "?"
        }

        tempoSlider?.value = musicPlayer?.tempo ?? 100
    }

}
