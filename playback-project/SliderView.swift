//
//  SliderView.swift
//  playback-project
//
//  Created by Jacob Parker on 15/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit

class SliderView: UIView {

    @IBInspectable
    var color: UIColor = UIColor.blueColor() {
        didSet {
            valueLabel?.textColor = color
        }
    }
    @IBInspectable
    var lineWidth: CGFloat = 1.0

    private let goldenRatio = (1 + sqrt(5.0)) / 2
    private let halfGoldenAngleDistanceFromHorizontal = (M_PI - (M_PI * (3.0 - sqrt(5)))) / 2

    private var value: Int = 100 {
        didSet {
            valueLabel?.text = String(value)
        }
    }

    private var defaultButton: UIButton?
    private var incrementButton: UIButton?
    private var decrementButton: UIButton?
    private var valueLabel: UILabel?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        valueLabel = UILabel()
        valueLabel!.textAlignment = .Center
        valueLabel!.textColor = color
        valueLabel!.text = String(value)
        valueLabel!.font = UIFont.monospacedDigitSystemFontOfSize(24, weight: UIFontWeightThin)
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

        valueLabel!.frame = defaultButton!.frame
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

        let incrementArrowLine = getSegment(
            CGPoint(x: incrementButton!.frame.midX, y: incrementButton!.frame.minY + lineWidth),
            radius: arrowRadius,
            startAngle: CGFloat(M_PI + halfGoldenAngleDistanceFromHorizontal),
            endAngle: CGFloat(M_PI * 2 - halfGoldenAngleDistanceFromHorizontal)
        )
        incrementArrowLine.lineWidth = lineWidth
        incrementArrowLine.stroke()

        colorForState(decrementButton!.state).set()

        let decrementArrowLine = getSegment(
            CGPoint(x: decrementButton!.frame.midX, y: decrementButton!.frame.maxY - lineWidth),
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

    func defaultAction(sender: AnyObject) {

    }

    func increment(sender: AnyObject) {
        value += 1
    }

    func decrement(sender: AnyObject) {
        value -= 1
    }

}
