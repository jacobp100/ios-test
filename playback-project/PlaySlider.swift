//
//  PlaySlider.swift
//  playback-project
//
//  Created by Jacob Parker on 18/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit

@IBDesignable
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
    private var previousButton = ShapeButton()
    private var nextButton = ShapeButton()
    private var sliderSize: CGFloat {
        get {
            return frame.size.height
        }
    }
    private var sliderPosition: CGFloat {
        get {
            return (frame.size.width - 3 * sliderSize) * CGFloat(value / (maximum - minimum))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        addSubview(playPauseButton)
        addSubview(previousButton)
        addSubview(nextButton)
    }

    override func layoutSubviews() {
        let width = frame.size.width
        let sliderWidth = width - 2 * sliderSize

        previousButton.frame = CGRect(x: 0, y: 0, width: sliderSize, height: sliderSize)
        playPauseButton.frame = CGRect(x: sliderSize, y: 0, width: sliderWidth, height: sliderSize)
        nextButton.frame = CGRect(x: width - sliderSize, y: 0, width: sliderSize, height: sliderSize)

        let playPausePath = UIBezierPath(ovalInRect: CGRect(
            x: sliderPosition + lineWidth / 2,
            y: lineWidth / 2,
            width: sliderSize - lineWidth,
            height: sliderSize - lineWidth
        ))
        playPausePath.moveToPoint(CGPoint(x: 0, y: bounds.midY))
        playPausePath.addLineToPoint(CGPoint(x: sliderPosition, y: playPauseButton.frame.midY))
        playPausePath.moveToPoint(CGPoint(x: sliderPosition + sliderSize, y: playPauseButton.frame.midY))
        playPausePath.addLineToPoint(CGPoint(x: sliderWidth, y: bounds.midY))

        playPauseButton.path = playPausePath.CGPath

        let previousNextPath = UIBezierPath(ovalInRect: CGRect(
            x: lineWidth / 2,
            y: lineWidth / 2,
            width: sliderSize - lineWidth,
            height: sliderSize - lineWidth
        ))

        previousButton.path = previousNextPath.CGPath
        nextButton.path = previousNextPath.CGPath
    }

}
