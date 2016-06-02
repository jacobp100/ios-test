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

    private var kvoContext: UInt8 = 1

    var musicPlayer: MusicPlayer? {
        didSet {
            setProperties()

            if let previousMusicPlayer = oldValue {
                previousMusicPlayer.removeObserver(self, forKeyPath: "pitch")
                previousMusicPlayer.removeObserver(self, forKeyPath: "tempo")
            }

            if let currentMusicPlayer = musicPlayer {
                currentMusicPlayer.addObserver(
                    self,
                    forKeyPath: "pitch",
                    options: .New,
                    context: &kvoContext
                )
                currentMusicPlayer.addObserver(
                    self,
                    forKeyPath: "tempo",
                    options: .New,
                    context: &kvoContext
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

    override func observeValueForKeyPath(
        keyPath: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>
    ) {
        setProperties()
    }


    func setProperties() {
        setPitchSliderProperties()
        setTempoSliderProperties()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func sliderViewDidChangeValue(slider: SliderView) {
        switch (slider) {
        case pitchSlider!:
            musicPlayer?.pitch = pitchSlider!.value
        case tempoSlider!:
            musicPlayer?.tempo = tempoSlider!.value
        default:
            print("Unknown slider. How do I throw real errors?")
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
