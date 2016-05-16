//
//  SliderView.swift
//  playback-project
//
//  Created by Jacob Parker on 15/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit
import Foundation

class SliderView: UIControl {

    @IBInspectable
    var color: UIColor = UIColor.blueColor() {
        didSet {
            titleLabel?.textColor = color
            valueLabel?.textColor = color
        }
    }
    @IBInspectable
    var lineWidth: CGFloat = 1.0
    @IBInspectable
    var value: Int = 50
    @IBInspectable
    var minimum: Int = 0
    @IBInspectable
    var maximum: Int = 100
    @IBInspectable
    var step: Int = 1
    @IBInspectable
    var stepsForHeight: Int = 5
    @IBInspectable
    var title: String = "" { didSet { titleLabel?.text = title.uppercaseString } }
    @IBInspectable
    var text: String = "" { didSet { valueLabel?.text = text } }

    private var defaultValue: Int!

    private let goldenRatio = (1 + sqrt(5.0)) / 2
    private let halfGoldenAngleDistanceFromHorizontal = (M_PI - (M_PI * (3.0 - sqrt(5)))) / 2

    private var defaultButton: UIButton?
    private var incrementButton: UIButton?
    private var decrementButton: UIButton?
    private var titleLabel: UILabel?
    private var valueLabel: UILabel?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let panGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(SliderView.handlePan(_:))
        )
        addGestureRecognizer(panGestureRecognizer)

        titleLabel = UILabel()
        titleLabel!.textAlignment = .Center
        titleLabel!.textColor = color
        titleLabel!.text = title
        addSubview(titleLabel!)

        valueLabel = UILabel()
        valueLabel!.textAlignment = .Center
        valueLabel!.textColor = color
        valueLabel!.text = text
        addSubview(valueLabel!)

        defaultButton = UIButton()
        defaultButton!.addTarget(
            self,
            action: #selector(SliderView.defaultAction(_:)),
            forControlEvents: .TouchDown
        )
        defaultButton!.addTarget(
            self,
            action: #selector(SliderView.setNeedsDisplay),
            forControlEvents: [.AllTouchEvents]
        )
        addSubview(defaultButton!)

        incrementButton = UIButton()
        incrementButton!.addTarget(
            self,
            action: #selector(SliderView.increment(_:)),
            forControlEvents: .TouchUpInside
        )
        incrementButton!.addTarget(
            self,
            action: #selector(SliderView.setNeedsDisplay),
            forControlEvents: [.AllTouchEvents]
        )
        addSubview(incrementButton!)

        decrementButton = UIButton()
        decrementButton!.addTarget(
            self,
            action: #selector(SliderView.decrement(_:)),
            forControlEvents: .TouchUpInside
        )
        decrementButton!.addTarget(
            self,
            action: #selector(SliderView.setNeedsDisplay),
            forControlEvents: [.AllTouchEvents]
        )
        addSubview(decrementButton!)
    }

    override func layoutSubviews() {
        let height = CGFloat(frame.size.height)
        let width = CGFloat(frame.size.width)

        incrementButton!.frame = CGRect(x: 0, y: 0, width: width, height: height * 0.25)
        defaultButton!.frame = CGRect(x: 0, y: height * 0.25, width: width, height: height * 0.5)
        decrementButton!.frame = CGRect(x: 0, y: height * 0.75, width: width, height: height * 0.25)

        valueLabel!.frame = CGRect(x: 0, y: height * 0.25, width: width, height: height * 0.475)
        valueLabel!.font = UIFont.monospacedDigitSystemFontOfSize(height * 0.1, weight: UIFontWeightThin)

        titleLabel!.frame = CGRect(x: 0, y: height * 0.5, width: width, height: height * 0.167)
        titleLabel!.font = UIFont.monospacedDigitSystemFontOfSize(height * 0.0333, weight: UIFontWeightMedium)
    }

    override func drawRect(rect: CGRect) {
        color.set()

        let radius = min(defaultButton!.frame.width, defaultButton!.frame.height) / 2 - lineWidth
        let centre = CGPoint(x: bounds.midX, y: bounds.midY)
        let arrowRadius = radius / CGFloat(goldenRatio)

        colorForState(defaultButton!.state).set()

        let circle = UIBezierPath(
            arcCenter: centre,
            radius: radius,
            startAngle: 0,
            endAngle: CGFloat(2 * M_PI),
            clockwise: true
        )
        circle.lineWidth = lineWidth
        circle.stroke()

        colorForState(incrementButton!.state).set()

        let incrementArrowStart = max(
            incrementButton!.frame.minY,
            incrementButton!.frame.maxY - arrowRadius
        )
        let incrementArrowLine = getSegment(
            CGPoint(x: incrementButton!.frame.midX, y: incrementArrowStart + lineWidth),
            radius: arrowRadius,
            startAngle: CGFloat(M_PI + halfGoldenAngleDistanceFromHorizontal),
            endAngle: CGFloat(M_PI * 2 - halfGoldenAngleDistanceFromHorizontal)
        )
        incrementArrowLine.lineWidth = lineWidth
        incrementArrowLine.stroke()

        colorForState(decrementButton!.state).set()

        let decrementArrowStart = min(
            decrementButton!.frame.maxY,
            decrementButton!.frame.minY + arrowRadius
        )
        let decrementArrowLine = getSegment(
            CGPoint(x: decrementButton!.frame.midX, y: decrementArrowStart - lineWidth),
            radius: arrowRadius,
            startAngle: CGFloat(halfGoldenAngleDistanceFromHorizontal),
            endAngle: CGFloat(M_PI - halfGoldenAngleDistanceFromHorizontal)
        )
        decrementArrowLine.lineWidth = lineWidth
        decrementArrowLine.stroke()
    }

    func getSegment(arcCenter: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) -> UIBezierPath {
        let line = UIBezierPath()

        line.moveToPoint(CGPoint(
            x: arcCenter.x + cos(startAngle) * radius,
            y: arcCenter.y - sin(startAngle) * radius
        ))
        line.addLineToPoint(arcCenter)
        line.addLineToPoint(CGPoint(
            x: arcCenter.x + cos(endAngle) * radius,
            y: arcCenter.y - sin(endAngle) * radius
        ))

        return line
    }

    func colorForState(state: UIControlState) -> UIColor {
        if state == .Highlighted {
            return color.colorWithAlphaComponent(0.5)
        } else {
            return color
        }
    }

    func handlePan(recognizer: UIPanGestureRecognizer) {
        let y = -recognizer.translationInView(self).y
        let minYChange = bounds.height / CGFloat(stepsForHeight)
        let change = round(y / minYChange)

        if change != 0 {
            recognizer.setTranslation(
                CGPoint(x: 0, y: 0),
                inView: self
            )
            incrementBy(Int(change))
            sendActionsForControlEvents(.ValueChanged)
        }
    }

    func defaultAction(sender: AnyObject) {

    }

    func incrementBy(inputValue: Int) {
        value = max(min(value + inputValue * step, maximum), minimum)
        sendActionsForControlEvents(.ValueChanged)
    }

    func increment(sender: AnyObject) {
        incrementBy(1)
    }

    func decrement(sender: AnyObject) {
        incrementBy(-1)
    }

}
