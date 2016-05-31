//
//  PitchTempoViewController.swift
//  playback-project
//
//  Created by Jacob Parker on 30/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit

protocol PitchTempoViewControllerDelegate {
    func pitchTempoPitchChanged(value: Int)
    func pitchTempoTempoChanged(value: Int)
}

class PitchTempoViewController: UIViewController, SliderViewDelegate {

    @IBOutlet weak var pitchSlider: SliderView?
    @IBOutlet weak var tempoSlider: SliderView?

    var pitch: Int = 0 {
        didSet {
            setPitchSliderProperties()
            delegate?.pitchTempoPitchChanged(pitch)
        }
    }
    var tempo: Int = 100 {
        didSet {
            setTempoSliderProperties()
            delegate?.pitchTempoTempoChanged(tempo)
        }
    }

    var delegate: PitchTempoViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        pitchSlider!.delegate = self
        tempoSlider!.delegate = self

        setPitchSliderProperties()
        setTempoSliderProperties()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func sliderViewDidChangeValue(slider: SliderView) {
        switch (slider) {
        case pitchSlider!:
            pitch = pitchSlider!.value
        case tempoSlider!:
            tempo = tempoSlider!.value
        default:
            print("Unknown slider. How do I throw real errors?")
        }
    }

    func sliderViewDidTap(slider: SliderView) {
    }

    func setPitchSliderProperties() {
        let pitchFormatter = NSNumberFormatter()
        pitchFormatter.positivePrefix = "+"
        pitchSlider?.text = pitchFormatter.stringFromNumber(pitch)!
        pitchSlider?.value = pitch
    }

    func setTempoSliderProperties() {
        tempoSlider?.text = "\(tempo)%"
        tempoSlider?.value = tempo
    }

}
