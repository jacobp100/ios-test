//
//  PlaySlider.swift
//  playback-project
//
//  Created by Jacob Parker on 18/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit

class PlaySlider: UIControl {

    @IBInspectable
    var color: UIColor = UIColor.whiteColor()
    @IBInspectable
    var lineWidth: CGFloat = 1.0
    @IBInspectable
    var value: Double = 50 { didSet { setNeedsLayout(); setNeedsDisplay() } }
    @IBInspectable
    var minimum: Double = 0 { didSet { setNeedsLayout() } }
    @IBInspectable
    var maximum: Double = 100 { didSet { setNeedsLayout() } }

    private var playPauseButton = ShapeButton()
    private var sliderSize: CGFloat {
        get {
            return frame.size.height
        }
    }
    private var sliderPosition: CGFloat {
        get {
            return (frame.size.width - frame.size.height) * CGFloat(value / (maximum - minimum))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addSubview(playPauseButton)
    }

    override func layoutSubviews() {
        playPauseButton.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: sliderSize)

        let path = UIBezierPath(ovalInRect: CGRect(x: sliderPosition, y: 0, width: sliderSize, height: sliderSize))
        path.moveToPoint(CGPoint(x: bounds.minX, y: bounds.midY))
        path.addLineToPoint(CGPoint(x: sliderPosition, y: playPauseButton.frame.midY))
        path.moveToPoint(CGPoint(x: sliderPosition + sliderSize, y: playPauseButton.frame.midY))
        path.addLineToPoint(CGPoint(x: bounds.maxX, y: bounds.midY))

        playPauseButton.path = path.CGPath
    }

}
