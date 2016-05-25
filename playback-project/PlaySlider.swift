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

    private var playPauseButton: UIButton?

    #if !TARGET_INTERFACE_BUILDER
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.tintAdjustmentMode = .Dimmed

        playPauseButton = UIButton(type: .System)
        playPauseButton?.setTitle("a", forState: .Normal)
        playPauseButton!.layer.borderColor = color.CGColor
        playPauseButton!.layer.borderWidth = lineWidth
        addSubview(playPauseButton!)
    }
    #endif

    override func layoutSubviews() {
        let height = CGFloat(frame.size.height)
        let width = CGFloat(frame.size.width)

        let sliderPosition = (width - height) * CGFloat(value / (maximum - minimum))

        playPauseButton!.frame = CGRect(x: sliderPosition, y: 0, width: height, height: height)
        playPauseButton!.layer.cornerRadius = height / 2
    }

    override func drawRect(rect: CGRect) {
        tintColor.set()

        let leftLine = UIBezierPath()
        leftLine.moveToPoint(CGPoint(x: bounds.minX, y: bounds.midY))
        leftLine.addLineToPoint(CGPoint(x: playPauseButton!.frame.minX, y: playPauseButton!.frame.midY))
        leftLine.lineWidth = lineWidth
        leftLine.lineCapStyle = .Square
        leftLine.stroke()

        let rightLine = UIBezierPath()
        rightLine.moveToPoint(CGPoint(x: playPauseButton!.frame.maxX, y: playPauseButton!.frame.midY))
        rightLine.addLineToPoint(CGPoint(x: bounds.maxX, y: bounds.midY))
        rightLine.lineWidth = lineWidth
        rightLine.lineCapStyle = .Square
        rightLine.stroke()
    }

}
