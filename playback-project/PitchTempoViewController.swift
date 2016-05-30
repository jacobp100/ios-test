//
//  PitchTempoViewController.swift
//  playback-project
//
//  Created by Jacob Parker on 30/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit

protocol PitchTempoViewControllerDelegate {
    func pitchChanged(value: Int)
    func tempoChanged(value: Int)
}

class PitchTempoViewController: UIViewController, SliderViewDelegate {

    @IBOutlet weak var pitchSlider: SliderView?
    @IBOutlet weak var tempoSlider: SliderView?

    var pitch: Int = 0 {
        didSet {
            setPitchSliderText()
            delegate?.pitchChanged(pitch)
        }
    }
    var tempo: Int = 100 {
        didSet {
            setTempoSliderText()
            delegate?.tempoChanged(tempo)
        }
    }

    var delegate: PitchTempoViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        pitchSlider!.delegate = self
        tempoSlider!.delegate = self

        setPitchSliderText()
        setTempoSliderText()
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

    func setPitchSliderText() {
        pitchSlider?.text = pitch >= 0
            ? "+\(pitch)"
            : "\(pitch)"
    }

    func setTempoSliderText() {
        tempoSlider?.text = "\(tempo)%"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
