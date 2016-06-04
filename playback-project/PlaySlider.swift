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

extension CGRect {
    func moveTo(x x: CGFloat, y: CGFloat) -> CGRect {
        return self.offsetBy(dx: x - self.minX, dy: y - self.minY)
    }
}

@IBDesignable
class PlaySlider: UIControl {

    @IBInspectable
    var color: UIColor = UIColor.whiteColor() { didSet { setColor() } }
    @IBInspectable
    var lineWidth: CGFloat = 1.0
    @IBInspectable
    var time: Double = 0 { didSet { setNeedsLayout() } }
    @IBInspectable
    var duration: Double? = nil { didSet { setNeedsLayout() }  }
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
    @IBInspectable
    var jumplistSize: CGFloat = 5
    @IBInspectable
    var jumplistDragSnap: CGFloat = 5
    @IBInspectable
    var jumplistTapSnap: CGFloat = 10

    var delegate: PlaySliderDelegate?
    var jumplistItems: [Double] = []

    private var playPauseButton = ShapeButton()
    private var previousButton = ShapeButton()
    private var nextButton = ShapeButton()
    private var currentTimeLabel = UILabel()
    private var totalDurationLabel = UILabel()
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var isDragging = false
    private var dragPosition: Double = -1 { didSet { setNeedsLayout() } }
    private var padding: CGFloat = 8
    private var sliderSize: CGFloat {
        get {
            return frame.size.height - currentTimeLabel.frame.height - padding - jumplistSize
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
                : time
            if let currentDuration = duration {
                return (frame.size.width - 3 * sliderSize) * CGFloat(sliderValue / currentDuration)
            }
            return 0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        panGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )
        addGestureRecognizer(panGestureRecognizer)

        tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap(_:))
        )
        tapGestureRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(tapGestureRecognizer)

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
            if let t = tForGesture(recognizer, snap: jumplistDragSnap) {
                dragPosition = t
            }
        default:
            break
        }
    }

    func handleTap(recognizer: UITapGestureRecognizer) {
        if let t = tForGesture(recognizer, snap: jumplistTapSnap) {
            delegate?.playSliderValueDidChange(self, value: t)
        }
    }

    override func layoutSubviews() {
        let width = frame.size.width
        let height = frame.size.height

        layoutLabel(currentTimeLabel, value: isDragging ? dragPosition : time)
        layoutLabel(totalDurationLabel, value: duration)

        currentTimeLabel.frame = currentTimeLabel.frame.moveTo(
            x: 0,
            y: height - currentTimeLabel.frame.height
        )
        totalDurationLabel.frame = totalDurationLabel.frame.moveTo(
            x: width - totalDurationLabel.frame.width,
            y: height - totalDurationLabel.frame.height
        )

        previousButton.frame = CGRect(x: 0, y: jumplistSize, width: sliderSize, height: sliderSize)
        playPauseButton.frame = CGRect(x: sliderSize, y: jumplistSize, width: sliderWidth, height: sliderSize)
        nextButton.frame = CGRect(x: width - sliderSize, y: jumplistSize, width: sliderSize, height: sliderSize)

        let sliderValue = isDragging && dragPosition >= 0
            ? dragPosition
            : time

        let playPausePath = UIBezierPath()
        if let sliderPosition = getSliderPosition(sliderValue) {
            drawSlider(playPausePath, sliderPosition: sliderPosition)
        }
        playPauseButton.path = playPausePath.CGPath

        let buttonRect = rectForButton()

        let previousPath = UIBezierPath()
        drawCircleInRect(previousPath, frame: buttonRect)
        drawPreviousButton(previousPath, frame: buttonRect)

        let nextPath = UIBezierPath()
        drawCircleInRect(nextPath, frame: buttonRect)
        drawNextButton(nextPath, frame: buttonRect)

        previousButton.path = previousPath.CGPath
        nextButton.path = nextPath.CGPath
    }

    func layoutLabel(label: UILabel, value: Double?) {
        if let currentValue = value where currentValue >= 0 { // FIXME
            let formatter = NSDateComponentsFormatter()
            formatter.zeroFormattingBehavior = .Pad
            formatter.allowedUnits = [.Minute, .Second]
            label.text = formatter.stringFromTimeInterval(currentValue)
        } else {
            label.text = "-"
        }
        label.sizeToFit()
    }

    func setColor() {
        playPauseButton.strokeColor = color
        previousButton.strokeColor = color
        nextButton.strokeColor = color
        currentTimeLabel.textColor = color
        totalDurationLabel.textColor = color
    }

    private func rectForButton() -> CGRect {
        return rectForButton(0)
    }

    private func rectForButton(position: CGFloat) -> CGRect {
        return CGRect(
            x: position,
            y: 0,
            width: sliderSize,
            height: sliderSize
        )
    }

    private func drawSlider(ctx: UIBezierPath, sliderPosition: CGFloat) {
        let sliderY = playPauseButton.frame.midY - jumplistSize

        let playPauseButtonFrame = rectForButton(sliderPosition)

        jumplistItems.forEach {
            value in
            let x = getSliderPosition(value)! + sliderSize / 2
            let centrePoint = CGPoint(x: x, y: sliderY)
            var y = sliderY

            if playPauseButtonFrame.contains(centrePoint) {
                let r = sliderSize / 2 - lineWidth / 2
                let x = x - playPauseButtonFrame.midX
                let dy = abs(x) < r
                    ? sqrt(pow(r, 2) - pow(x, 2))
                    : 0
                y -= dy
            }

            drawLineBetween(ctx, x: x, y1: y, y2: y - jumplistSize)
        }

        drawPauseButton(ctx, frame: playPauseButtonFrame)
        drawCircleInRect(ctx, frame: playPauseButtonFrame)
        drawLineBetween(ctx, x1: 0, x2: playPauseButtonFrame.minX, y: sliderY)
        drawLineBetween(ctx, x1: playPauseButtonFrame.maxX, x2: sliderWidth, y: sliderY)
    }

    private func drawCircleInRect(ctx: UIBezierPath, frame: CGRect) {
        let dx = lineWidth / 2
        ctx.appendPath(UIBezierPath(ovalInRect: frame.insetBy(dx: dx, dy: dx)))
    }

    private func drawLineBetween(ctx: UIBezierPath, x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat) {
        ctx.moveToPoint(CGPoint(x: x1, y: y1))
        ctx.addLineToPoint(CGPoint(x: x2, y: y2))
    }

    private func drawLineBetween(ctx: UIBezierPath, x1: CGFloat, x2: CGFloat, y: CGFloat) {
        drawLineBetween(ctx, x1: x1, x2: x2, y1: y, y2: y)
    }

    private func drawLineBetween(ctx: UIBezierPath, x: CGFloat, y1: CGFloat, y2: CGFloat) {
        drawLineBetween(ctx, x1: x, x2: x, y1: y1, y2: y2)
    }

    private func getDrawButtonBounds(frame: CGRect) -> (x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat) {
        let x1 = frame.minX + frame.width * 5 / 13
        let x2 = frame.minX + frame.width * 8 / 13
        let y1 = frame.minY + frame.height * 1 / 3
        let y2 = frame.minY + frame.height * 2 / 3
        return (x1, x2, y1, y2)
    }

    private func drawPauseButton(ctx: UIBezierPath, frame: CGRect) {
        let (x1, x2, y1, y2) = getDrawButtonBounds(frame)
        drawLineBetween(ctx, x: x1, y1: y1, y2: y2)
        drawLineBetween(ctx, x: x2, y1: y1, y2: y2)
    }

    private func drawPreviousButton(ctx: UIBezierPath, frame: CGRect) {
        let (x1, x2, y1, y2) = getDrawButtonBounds(frame)
        drawLineBetween(ctx, x: x1, y1: y1, y2: y2)
        ctx.moveToPoint(CGPoint(x: x2, y: y1))
        ctx.addLineToPoint(CGPoint(x: x2, y: y2))
        ctx.addLineToPoint(CGPoint(x: x1 + lineWidth, y: (y2 - y1) / 2 + y1))
        ctx.closePath()
    }

    private func drawNextButton(ctx: UIBezierPath, frame: CGRect) {
        let (x1, x2, y1, y2) = getDrawButtonBounds(frame)
        drawLineBetween(ctx, x: x2, y1: y1, y2: y2)
        ctx.moveToPoint(CGPoint(x: x1, y: y1))
        ctx.addLineToPoint(CGPoint(x: x1, y: y2))
        ctx.addLineToPoint(CGPoint(x: x2 - lineWidth, y: (y2 - y1) / 2 + y1))
        ctx.closePath()
    }

    private func getSliderPosition(value: Double) -> CGFloat? {
        if let currentDuration = duration {
            return (frame.size.width - 3 * sliderSize) * CGFloat(value / currentDuration)
        }
        return nil
    }

    private func tForGesture(recognizer: UIGestureRecognizer, snap: CGFloat) -> Double? {
        let x = recognizer.locationInView(self).x - sliderSize * 1.5

        func distanceToX(value: Double) -> CGFloat {
            if let valueX = getSliderPosition(value) {
                return abs(valueX - x)
            }
            return CGFloat.infinity
        }

        let tToSnap = jumplistItems
            .filter { distanceToX($0) < snap }
            .sort { distanceToX($0) < distanceToX($1) }
            .first

        if let t = tToSnap {
            return t
        }

        var t = x / (sliderWidth - sliderSize)
        t = min(max(t, 0), 1)
        if let currentDuration = duration {
            return Double(t) * currentDuration
        }
        return nil
    }

}
