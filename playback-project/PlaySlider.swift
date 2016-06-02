//
//  PlaySlider.swift
//  playback-project
//
//  Created by Jacob Parker on 18/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit

protocol PlaySliderDelegate {
    func playSliderDidTogglePlaying(playSlider: PlaySlider)
    func playSliderValueDidChange(playSlider: PlaySlider, value: Double)
}

@IBDesignable
class PlaySlider: UIControl {

    @IBInspectable
    var color: UIColor = UIColor.whiteColor() { didSet { setColor() } }
    @IBInspectable
    var lineWidth: CGFloat = 1.0
    @IBInspectable
    var currentTime: Double = 0 { didSet { setNeedsLayout() } }
    @IBInspectable
    var totalDuration: Double = 100 { didSet { setNeedsLayout() }  }
    @IBInspectable
    var font: UIFont = UIFont.monospacedDigitSystemFontOfSize(
        UIFont.smallSystemFontSize(),
        weight: UIFontWeightRegular
    ) {
        didSet {
            currentTimeLabel.font = font
            totalDurationLabel.font = font
            setNeedsLayout()
        }
    }

    var delegate: PlaySliderDelegate?

    private var playPauseButton = ShapeButton()
    private var previousButton = ShapeButton()
    private var nextButton = ShapeButton()
    private var currentTimeLabel = UILabel()
    private var totalDurationLabel = UILabel()
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var isDragging = false
    private var dragPosition: Double = -1 { didSet { setNeedsLayout() } }
    private var padding: CGFloat = 8
    private var sliderSize: CGFloat {
        get {
            return frame.size.height - currentTimeLabel.frame.height - padding
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
                : currentTime
            return (frame.size.width - 3 * sliderSize) * CGFloat(sliderValue / totalDuration)
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
        currentTimeLabel.font = font
        totalDurationLabel.font = font

        addSubview(playPauseButton)
        addSubview(previousButton)
        addSubview(nextButton)
        addSubview(currentTimeLabel)
        addSubview(totalDurationLabel)

        setColor()
    }

    func playButtonPressed() {
        delegate?.playSliderDidTogglePlaying(self)
    }

    func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            isDragging = true
        case .Ended:
            delegate?.playSliderValueDidChange(self, value: dragPosition)
            isDragging = false
            dragPosition = -1
        case .Changed:
            var t = (recognizer.locationInView(self).x - sliderSize * 1.5) / (sliderWidth - sliderSize)
            t = min(max(t, 0), 1)
            dragPosition = Double(t) * totalDuration
        default:
            break
        }
    }

    override func layoutSubviews() {
        let width = frame.size.width
        let height = frame.size.height

        layoutLabel(currentTimeLabel, value: isDragging ? dragPosition : currentTime)
        layoutLabel(totalDurationLabel, value: totalDuration)

        currentTimeLabel.frame = CGRect(
            x: 0,
            y: height - currentTimeLabel.frame.height,
            width: currentTimeLabel.frame.width,
            height: currentTimeLabel.frame.height
        )
        totalDurationLabel.frame = CGRect(
            x: width - totalDurationLabel.frame.width,
            y: height - totalDurationLabel.frame.height,
            width: totalDurationLabel.frame.width,
            height: totalDurationLabel.frame.height
        )

        previousButton.frame = CGRect(x: 0, y: 0, width: sliderSize, height: sliderSize)
        playPauseButton.frame = CGRect(x: sliderSize, y: 0, width: sliderWidth, height: sliderSize)
        nextButton.frame = CGRect(x: width - sliderSize, y: 0, width: sliderSize, height: sliderSize)

        let playPauseButtonRect = rectForButton(sliderPosition)

        let sliderY = playPauseButton.frame.midY
        let playPausePath = UIBezierPath()
        drawButtonOutline(playPausePath, frame: playPauseButtonRect)
        drawPauseButton(playPausePath, frame: playPauseButtonRect)
        playPausePath.moveToPoint(CGPoint(x: 0, y: sliderY))
        playPausePath.addLineToPoint(CGPoint(x: sliderPosition, y: sliderY))
        playPausePath.moveToPoint(CGPoint(x: sliderPosition + sliderSize, y: sliderY))
        playPausePath.addLineToPoint(CGPoint(x: sliderWidth, y: sliderY))

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

    func layoutLabel(label: UILabel, value: Double) {
        let minutes = Int(value / 60)
        let seconds = String(format: "%02d", Int(value) % 60)
        label.text = "\(minutes):\(seconds)"
        label.sizeToFit()
    }

    func setColor() {
        playPauseButton.strokeColor = color
        previousButton.strokeColor = color
        nextButton.strokeColor = color
        currentTimeLabel.textColor = color
        totalDurationLabel.textColor = color
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
        let dx = lineWidth / 2
        ctx.appendPath(UIBezierPath(ovalInRect: frame.insetBy(dx: dx, dy: dx)))
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
