//
//  SliderView.swift
//  playback-project
//
//  Created by Jacob Parker on 15/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
class SliderView: UIControl {

    @IBInspectable
    var color: UIColor = UIColor.whiteColor() {
        didSet {
            titleLabel.textColor = color
            valueLabel.textColor = color
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
    var title: String = "" { didSet { titleLabel.text = title.uppercaseString } }
    @IBInspectable
    var text: String = "" { didSet { valueLabel.text = text } }

    private var defaultValue: Int!

    private let goldenRatio = (1 + sqrt(5.0)) / 2
    private let halfGoldenAngleDistanceFromHorizontal = (M_PI - (M_PI * (3.0 - sqrt(5)))) / 2

    private var defaultButton = ShapeButton()
    private var incrementButton = ShapeButton()
    private var decrementButton = ShapeButton()
    private var titleLabel = UILabel()
    private var valueLabel = UILabel()
    private var panGestureRecognizer: UIPanGestureRecognizer!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        panGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(SliderView.handlePan(_:))
        )
        addGestureRecognizer(panGestureRecognizer)

        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        titleLabel.textAlignment = .Center
        titleLabel.textColor = color
        titleLabel.text = title
        addSubview(titleLabel)

        valueLabel.textAlignment = .Center
        valueLabel.textColor = color
        valueLabel.text = text
        addSubview(valueLabel)

        defaultButton.addTarget(
            self,
            action: #selector(SliderView.defaultAction(_:)),
            forControlEvents: .TouchDown
        )
        defaultButton.addTarget(
            self,
            action: #selector(SliderView.setNeedsDisplay),
            forControlEvents: [.AllTouchEvents]
        )
        addSubview(defaultButton)

        incrementButton.addTarget(
            self,
            action: #selector(SliderView.increment(_:)),
            forControlEvents: .TouchUpInside
        )
        incrementButton.addTarget(
            self,
            action: #selector(SliderView.setNeedsDisplay),
            forControlEvents: [.AllTouchEvents]
        )
        addSubview(incrementButton)

        decrementButton.addTarget(
            self,
            action: #selector(SliderView.decrement(_:)),
            forControlEvents: .TouchUpInside
        )
        decrementButton.addTarget(
            self,
            action: #selector(SliderView.setNeedsDisplay),
            forControlEvents: [.AllTouchEvents]
        )
        addSubview(decrementButton)
    }

    override func layoutSubviews() {
        let height = CGFloat(frame.size.height)
        let width = CGFloat(frame.size.width)
        let arrowHeight = (height - width) / 2

        incrementButton.frame = CGRect(x: 0, y: 0, width: width, height: arrowHeight)
        defaultButton.frame = CGRect(x: 0, y: arrowHeight, width: width, height: width)
        decrementButton.frame = CGRect(x: 0, y: height - arrowHeight, width: width, height: arrowHeight)

        let radius = width / 2 - lineWidth
        let arrowHorizontalOrigin = width / 2
        let arrowVerticalOrigin = width / 2
        let arrowRadius = width / (2 * CGFloat(goldenRatio))

        incrementButton.path = getSegment(
            CGPoint(x: arrowHorizontalOrigin, y: max(arrowHeight - arrowVerticalOrigin, 0)),
            radius: arrowRadius,
            startAngle: CGFloat(M_PI + halfGoldenAngleDistanceFromHorizontal),
            endAngle: CGFloat(M_PI * 2 - halfGoldenAngleDistanceFromHorizontal)
        ).CGPath

        decrementButton.path = getSegment(
            CGPoint(x: arrowHorizontalOrigin, y: min(arrowVerticalOrigin, arrowHeight)),
            radius: arrowRadius,
            startAngle: CGFloat(halfGoldenAngleDistanceFromHorizontal),
            endAngle: CGFloat(M_PI - halfGoldenAngleDistanceFromHorizontal)
        ).CGPath

        defaultButton.path = UIBezierPath(
            arcCenter: CGPoint(x: width / 2, y: width / 2),
            radius: radius,
            startAngle: 0,
            endAngle: CGFloat(M_PI * 2),
            clockwise: true
        ).CGPath

        valueLabel.frame = CGRect(x: 0, y: height * 0.25, width: width, height: height * 0.475)
        valueLabel.font = UIFont.monospacedDigitSystemFontOfSize(radius * 0.6, weight: UIFontWeightThin)

        titleLabel.frame = CGRect(x: 0, y: height * 0.5, width: width, height: height * 0.167)
        titleLabel.font = UIFont.monospacedDigitSystemFontOfSize(radius * 0.15, weight: UIFontWeightMedium)
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
