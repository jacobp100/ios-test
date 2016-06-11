//
//  ShapeButton.swift
//  playback-project
//
//  Created by Jacob Parker on 25/05/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import UIKit

class ShapeButton: UIButton {

    @IBInspectable var strokeColor: UIColor = UIColor.whiteColor() {
        didSet {
            setStrokeColor()
        }
    }

    @IBInspectable var lineWidth: CGFloat = 1.0 {
        didSet {
            shapeLayer.lineWidth = lineWidth
        }
    }

    var path: CGPath? {
        didSet {
            shapeLayer.path = path
        }
    }

    private var shapeLayer = CAShapeLayer()

    override var highlighted: Bool {
        didSet {
            if oldValue != highlighted {
                setStrokeColor()
            }
        }
    }

    override func didMoveToSuperview() {
        // Populate defaults
        shapeLayer.strokeColor = strokeColor.CGColor
        shapeLayer.lineWidth = lineWidth

        // Clear default fill
        shapeLayer.fillColor = UIColor.clearColor().CGColor

        layer.addSublayer(shapeLayer)
    }

    func setStrokeColor() {
        let fromColor = strokeColorWhenHighlighted(!highlighted)
        let toColor = strokeColorWhenHighlighted(highlighted)

        let color = CABasicAnimation(keyPath: "strokeColor")
        color.fromValue = fromColor
        color.toValue = toColor
        color.duration = highlighted
            ? 0.05
            : 0.2
        shapeLayer.strokeColor = toColor
        shapeLayer.addAnimation(color, forKey: "shapeAnimation")
    }

    func strokeColorWhenHighlighted(highlighted: Bool) -> CGColor {
        return highlighted
            ? strokeColor.colorWithAlphaComponent(0.33).CGColor
            : strokeColor.CGColor
    }

}
