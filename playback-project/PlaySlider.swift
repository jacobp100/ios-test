//
//  PlaySlider.swift
//  playback-project
//
//  Created by Jacob Parker on 18/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit

protocol PlaySliderDelegate {
    func playSliderDidTogglePlaying()
    func playSliderValueDidChange(value: Double)
}

@IBDesignable
class PlaySlider: UIControl {

    @IBInspectable
    var color: UIColor = UIColor.whiteColor()
    @IBInspectable
    var lineWidth: CGFloat = 1.0
    @IBInspectable
    var value: Double = 50 { didSet { setNeedsLayout() } }
    @IBInspectable
    var minimum: Double = 0 { didSet { setNeedsLayout() } }
    @IBInspectable
    var maximum: Double = 100 { didSet { setNeedsLayout() } }

    var delegate: PlaySliderDelegate?

    private var playPauseButton = ShapeButton()
    private var previousButton = ShapeButton()
    private var nextButton = ShapeButton()
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var isDragging = false
    private var dragPosition: CGFloat = -1 { didSet { setNeedsLayout() } }
    private var sliderSize: CGFloat {
        get {
            return frame.size.height
        }
    }
    private var sliderWidth: CGFloat {
        get {
            return frame.size.width - 2 * sliderSize
        }
    }
    private var sliderPosition: CGFloat {
        get {
            let sliderValue = isDragging && dragPosition >= 0
                ? dragPosition
                : CGFloat(value)
            return (frame.size.width - 3 * sliderSize) * sliderValue / CGFloat(maximum - minimum)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        panGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(SliderView.handlePan(_:))
        )
        addGestureRecognizer(panGestureRecognizer)

        playPauseButton.addTarget(
            self,
            action: #selector(PlaySlider.playButtonPressed),
            forControlEvents: .TouchUpInside
        )

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

        previousButton.frame = CGRect(x: 0, y: 0, width: sliderSize, height: sliderSize)
        playPauseButton.frame = CGRect(x: sliderSize, y: 0, width: sliderWidth, height: sliderSize)
        nextButton.frame = CGRect(x: width - sliderSize, y: 0, width: sliderSize, height: sliderSize)

        let playPauseButtonRect = rectForButton(sliderPosition)

        let playPausePath = UIBezierPath()
        drawButtonOutline(playPausePath, frame: playPauseButtonRect)
        drawPauseButton(playPausePath, frame: playPauseButtonRect)
        playPausePath.moveToPoint(CGPoint(x: 0, y: bounds.midY))
        playPausePath.addLineToPoint(CGPoint(x: sliderPosition, y: playPauseButton.frame.midY))
        playPausePath.moveToPoint(CGPoint(x: sliderPosition + sliderSize, y: playPauseButton.frame.midY))
        playPausePath.addLineToPoint(CGPoint(x: sliderWidth, y: bounds.midY))

        playPauseButton.path = playPausePath.CGPath

        let buttonRect = rectForButton()

        let previousPath = UIBezierPath()
        drawButtonOutline(previousPath, frame: buttonRect)
        drawPreviousButton(previousPath, frame: buttonRect)

        let nextPath = UIBezierPath()
        drawButtonOutline(nextPath, frame: buttonRect)
        drawNextButton(nextPath, frame: buttonRect)

        previousButton.path = previousPath.CGPath
        nextButton.path = nextPath.CGPath
    }

    func playButtonPressed() {
        delegate?.playSliderDidTogglePlaying()
    }

    func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            isDragging = true
        case .Ended:
            delegate?.playSliderValueDidChange(Double(dragPosition))
            isDragging = false
            dragPosition = -1
        case .Changed:
            var t = (recognizer.locationInView(self).x - sliderSize * 1.5) / (sliderWidth - sliderSize)
            t = min(max(t, 0), 1)
            dragPosition = t * CGFloat((maximum - minimum) + minimum)
        default:
            break
        }
    }

    func rectForButton() -> CGRect {
        return rectForButton(0)
    }

    func rectForButton(position: CGFloat) -> CGRect {
        return CGRect(
            x: position,
            y: 0,
            width: sliderSize,
            height: sliderSize
        )
    }

    func drawButtonOutline(ctx: UIBezierPath, frame: CGRect) {
        ctx.appendPath(UIBezierPath(ovalInRect: CGRect(
            x: frame.minX + lineWidth / 2,
            y: frame.minY + lineWidth / 2,
            width: frame.width - lineWidth,
            height: frame.height - lineWidth
        )))
    }

    func getDrawButtonBounds(frame: CGRect) -> (x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat) {
        let x1 = frame.minX + frame.width * 5 / 13
        let x2 = frame.minX + frame.width * 8 / 13
        let y1 = frame.minY + frame.height * 1 / 3
        let y2 = frame.minY + frame.height * 2 / 3
        return (x1, x2, y1, y2)
    }

    func drawPauseButton(ctx: UIBezierPath, frame: CGRect) {
        let (x1, x2, y1, y2) = getDrawButtonBounds(frame)
        ctx.moveToPoint(CGPoint(x: x1, y: y1))
        ctx.addLineToPoint(CGPoint(x: x1, y: y2))
        ctx.moveToPoint(CGPoint(x: x2, y: y1))
        ctx.addLineToPoint(CGPoint(x: x2, y: y2))
    }

    func drawPreviousButton(ctx: UIBezierPath, frame: CGRect) {
        let (x1, x2, y1, y2) = getDrawButtonBounds(frame)
        ctx.moveToPoint(CGPoint(x: x1, y: y1))
        ctx.addLineToPoint(CGPoint(x: x1, y: y2))
        ctx.moveToPoint(CGPoint(x: x2, y: y1))
        ctx.addLineToPoint(CGPoint(x: x2, y: y2))
        ctx.addLineToPoint(CGPoint(x: x1 + lineWidth, y: (y2 - y1) / 2 + y1))
        ctx.closePath()
    }

    func drawNextButton(ctx: UIBezierPath, frame: CGRect) {
        let (x1, x2, y1, y2) = getDrawButtonBounds(frame)
        ctx.moveToPoint(CGPoint(x: x2, y: y1))
        ctx.addLineToPoint(CGPoint(x: x2, y: y2))
        ctx.moveToPoint(CGPoint(x: x1, y: y1))
        ctx.addLineToPoint(CGPoint(x: x1, y: y2))
        ctx.addLineToPoint(CGPoint(x: x2 - lineWidth, y: (y2 - y1) / 2 + y1))
        ctx.closePath()
    }

}
