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
    func playSliderLoopDidChange(playSlider: PlaySlider, loop: Loop)
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

    var loop: Loop?
    var delegate: PlaySliderDelegate?
    var jumplistItems: [JumplistItem] = []

    private enum DragItem {
        case None
        case Time
        case Start
        case End
    }

    private var playPauseButton = ShapeButton()
    private var previousButton = ShapeButton()
    private var nextButton = ShapeButton()
    private var currentTimeLabel = UILabel()
    private var totalDurationLabel = UILabel()
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var isDragging = false
    private var dragItem: DragItem = .None
    private var dragPosition: Double? { didSet { setNeedsLayout() } }
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
            let timeValue = dragItem == .Time ? (dragPosition ?? time) : time
            if let currentDuration = duration {
                return (frame.size.width - 3 * sliderSize) * CGFloat(timeValue / currentDuration)
            }
            return 0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        [playPauseButton, previousButton, nextButton].forEach {
            $0.addTarget(
                self,
                action: #selector(setDragItem(_:)),
                forControlEvents: .TouchDown
            )
        }

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
            action: #selector(playButtonPressed),
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
        if dragItem == .Time {
            delegate?.playSliderDidTogglePlaying(self)
        }
        dragItem = .None
    }

    func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            isDragging = true
        case .Ended:
            let currentDragPosition = dragPosition
            isDragging = false
            dragPosition = nil

            guard let position = currentDragPosition else {
                return
            }

            if dragItem == .Time {
                delegate?.playSliderValueDidChange(self, value: position)
            } else if let end = loop?.end where dragItem == .Start {
                let newLoop = Loop(start: position, end: end)
                delegate?.playSliderLoopDidChange(self, loop: newLoop)
            } else if let start = loop?.start where dragItem == .End {
                let newLoop = Loop(start: start, end: position)
                delegate?.playSliderLoopDidChange(self, loop: newLoop)
            }
        case .Changed:
            guard let t = tForGesture(recognizer, snap: jumplistDragSnap) else {
                return
            }

            if let end = loop?.end where dragItem == .Start {
                dragPosition = min(t, end)
            } else if let start = loop?.start where dragItem == .End {
                dragPosition = max(t, start)
            } else {
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

    func setDragItem(sender: AnyObject) {
        if sender === playPauseButton {
            dragItem = .Time
        } else if sender === previousButton {
            dragItem = .Start
        } else if sender === nextButton {
            dragItem = .End
        }
    }

    override func layoutSubviews() {
        let width = frame.size.width
        let height = frame.size.height

        let currentTime = dragItem == .Time ? (dragPosition ?? time) : time
        var loopStart: Double?
        var loopEnd: Double?

        if let currentLoop = loop {
            loopStart = dragItem == .Start ? (dragPosition ?? currentLoop.start) : currentLoop.start
            loopEnd = dragItem == .End ? (dragPosition ?? currentLoop.end) : currentLoop.end
        }

        layoutLabel(currentTimeLabel, value: loopStart ?? currentTime)
        layoutLabel(totalDurationLabel, value: loopEnd ?? duration)

        currentTimeLabel.frame = currentTimeLabel.frame.moveTo(
            x: 0,
            y: height - currentTimeLabel.frame.height
        )
        totalDurationLabel.frame = totalDurationLabel.frame.moveTo(
            x: width - totalDurationLabel.frame.width,
            y: height - totalDurationLabel.frame.height
        )

        if let startValue = loopStart, endValue = loopEnd {
            guard let startPosition = getSliderPosition(startValue), let endPosition = getSliderPosition(endValue) else {
                return
            }

            let basePreviousNextFrame = CGRect(x: 0, y: jumplistSize, width: 1.5 * sliderSize, height: sliderSize)
            previousButton.frame = basePreviousNextFrame.offsetBy(dx: startPosition, dy: 0)
            nextButton.frame = basePreviousNextFrame.offsetBy(dx: endPosition + 1.5 * sliderSize, dy: 0)
        } else {
            let basePreviousNextFrame = CGRect(x: 0, y: jumplistSize, width: sliderSize, height: sliderSize)
            previousButton.frame = basePreviousNextFrame
            nextButton.frame = basePreviousNextFrame.offsetBy(dx: width - sliderSize, dy: 0)
        }

        playPauseButton.frame = CGRect(
            x: previousButton.frame.maxX,
            y: jumplistSize,
            width: nextButton.frame.minX - previousButton.frame.maxX,
            height: sliderSize
        )

        drawPreviousNextButtons()

        if let startValue = loopStart, endValue = loopEnd {
            drawSlider(sliderPosition: nil, startValue: startValue, endValue: endValue)
        } else if let sliderPosition = getSliderPosition(currentTime) {
            drawSlider(sliderPosition: sliderPosition, startValue: nil, endValue: nil)
        } else {
            playPauseButton.path = nil
        }
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

    private func drawPreviousNextButtons() {
        let hasLoop = loop != nil

        let previousNextRect = CGRect(
            x: 0,
            y: 0,
            width: previousButton.frame.width,
            height: previousButton.frame.height
        )

        let previousPath = UIBezierPath()
        let nextPath = UIBezierPath()

        if hasLoop {
            previousPath.drawRightArrow(previousNextRect)
            nextPath.drawLeftArrow(previousNextRect)
        } else {
            previousPath.drawCircleWithinRect(previousNextRect)
            previousPath.drawPreviousButton(previousNextRect)

            nextPath.drawCircleWithinRect(previousNextRect)
            nextPath.drawNextButton(previousNextRect)
        }

        previousButton.path = previousPath.CGPath
        nextButton.path = nextPath.CGPath
    }

    private func drawSlider(sliderPosition sliderPosition: CGFloat?, startValue: Double?, endValue: Double?) {
        let playPausePath = UIBezierPath()

        let sliderY = playPauseButton.frame.midY - jumplistSize
        let sliderWidth = playPauseButton.frame.width
        let offset = playPauseButton.frame.minX - sliderSize

        var playPauseButtonFrame: CGRect?
        if let currentSliderPosition = sliderPosition {
            playPauseButtonFrame = CGRect(x: currentSliderPosition - offset, y: 0, width: sliderSize, height: sliderSize)
        }

        jumplistItems.forEach {
            jumplistItem in
            guard let time = jumplistItem.time as? Double else {
                return
            }

            if time < startValue || time > endValue {
                return
            }

            let x = getSliderPosition(time)! + sliderSize / 2 - offset
            let centrePoint = CGPoint(x: x, y: sliderY)
            var y = sliderY

            if let frame = playPauseButtonFrame where frame.contains(centrePoint) {
                let r = sliderSize / 2 - lineWidth / 2
                let x = x - frame.midX
                let dy = abs(x) < r
                    ? sqrt(pow(r, 2) - pow(x, 2))
                    : 0
                y -= dy
            }

            playPausePath.drawLineBetween(x: x, y1: y, y2: y - jumplistSize)
        }

        if let frame = playPauseButtonFrame {
            playPausePath.drawCircleWithinRect(frame)
            playPausePath.drawPauseButton(frame)
            playPausePath.drawLineBetween(x1: 0, x2: frame.minX, y: sliderY)
            playPausePath.drawLineBetween(x1: frame.maxX, x2: sliderWidth, y: sliderY)
        } else {
            playPausePath.drawLineBetween(x1: 0, x2: sliderWidth, y: sliderY)
        }

        playPauseButton.path = playPausePath.CGPath
    }

    private func getSliderPosition(value: Double) -> CGFloat? {
        if let currentDuration = duration {
            return (frame.size.width - 3 * sliderSize) * CGFloat(value / currentDuration)
        }
        return nil
    }

    private func tForGesture(recognizer: UIGestureRecognizer, snap: CGFloat) -> Double? {
        let x = recognizer.locationInView(self).x - sliderSize * 1.5

        func distanceToX(jumplistItem: JumplistItem) -> CGFloat {
            if let t = jumplistItem.time as? Double, let valueX = getSliderPosition(t) {
                return abs(valueX - x)
            }
            return CGFloat.infinity
        }

        let jumplistItemToSnap = jumplistItems
            .filter { distanceToX($0) < snap }
            .sort { distanceToX($0) < distanceToX($1) }
            .first

        if let jumplistItem = jumplistItemToSnap {
            return jumplistItem.time as? Double
        }

        var t = x / (sliderWidth - sliderSize)
        t = min(max(t, 0), 1)
        if let currentDuration = duration {
            return Double(t) * currentDuration
        }
        return nil
    }

}
