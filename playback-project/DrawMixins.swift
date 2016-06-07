//
//  DrawMixins.swift
//  playback-project
//
//  Created by Jacob Parker on 07/06/2016.
//  Copyright © 2016 Jacob Parker. All rights reserved.
//

import Foundation
import UIKit


func getDrawButtonBounds(frame: CGRect) -> (x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat) {
    let x1 = frame.minX + frame.width * 5 / 13
    let x2 = frame.minX + frame.width * 8 / 13
    let y1 = frame.minY + frame.height * 1 / 3
    let y2 = frame.minY + frame.height * 2 / 3
    return (x1, x2, y1, y2)
}

/* I'm completely unsure about some of these being an extension, but fuck it */
extension UIBezierPath {
    func drawCircleWithinRect(frame: CGRect) {
        let dx = lineWidth / 2
        appendPath(UIBezierPath(ovalInRect: frame.insetBy(dx: dx, dy: dx)))
    }

    func drawRightArrow(frame: CGRect) {
        let midY = frame.midY
        let leftOriginX = midY
        let rightOriginX = frame.width - CGFloat(M_SQRT2) * frame.height / 2
        let r = frame.height / 2 - lineWidth / 2

        addArcWithCenter(
            CGPoint(x: rightOriginX, y: midY),
            radius: r,
            startAngle: CGFloat(0.25 * M_PI),
            endAngle: CGFloat(0.5 * M_PI),
            clockwise: true
        )
        addLineToPoint(CGPoint(x: leftOriginX, y: frame.height - lineWidth / 2))
        addArcWithCenter(
            CGPoint(x: leftOriginX, y: midY),
            radius: r,
            startAngle: CGFloat(0.5 * M_PI),
            endAngle: CGFloat(1.5 * M_PI),
            clockwise: true
        )
        addLineToPoint(CGPoint(x: rightOriginX, y: lineWidth / 2))
        addArcWithCenter(
            CGPoint(x: rightOriginX, y: midY),
            radius: r,
            startAngle: CGFloat(1.5 * M_PI),
            endAngle: CGFloat(1.75 * M_PI),
            clockwise: true
        )
        addLineToPoint(CGPoint(x: frame.width - lineWidth / 2, y: midY))
        closePath()
    }

    func drawLeftArrow(frame: CGRect) {
        let midY = frame.midY
        let leftOriginX = CGFloat(M_SQRT2) * frame.height / 2
        let rightOriginX = frame.width - midY
        let r = frame.height / 2 - lineWidth / 2

        addArcWithCenter(
            CGPoint(x: leftOriginX, y: midY),
            radius: r,
            startAngle: CGFloat(0.75 * M_PI),
            endAngle: CGFloat(0.5 * M_PI),
            clockwise: false
        )
        addLineToPoint(CGPoint(x: rightOriginX, y: frame.height - lineWidth / 2))
        addArcWithCenter(
            CGPoint(x: rightOriginX, y: midY),
            radius: r,
            startAngle: CGFloat(0.5 * M_PI),
            endAngle: CGFloat(1.5 * M_PI),
            clockwise: false
        )
        addLineToPoint(CGPoint(x: leftOriginX, y: lineWidth / 2))
        addArcWithCenter(
            CGPoint(x: leftOriginX, y: midY),
            radius: r,
            startAngle: CGFloat(1.5 * M_PI),
            endAngle: CGFloat(1.25 * M_PI),
            clockwise: false
        )
        addLineToPoint(CGPoint(x: lineWidth / 2, y: midY))
        closePath()
    }

    func drawLineBetween(x1 x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat) {
        moveToPoint(CGPoint(x: x1, y: y1))
        addLineToPoint(CGPoint(x: x2, y: y2))
    }

    func drawLineBetween(x1 x1: CGFloat, x2: CGFloat, y: CGFloat) {
        drawLineBetween(x1: x1, x2: x2, y1: y, y2: y)
    }

    func drawLineBetween(x x: CGFloat, y1: CGFloat, y2: CGFloat) {
        drawLineBetween(x1: x, x2: x, y1: y1, y2: y2)
    }

    func drawPauseButton(frame: CGRect) {
        let (x1, x2, y1, y2) = getDrawButtonBounds(frame)
        drawLineBetween(x: x1, y1: y1, y2: y2)
        drawLineBetween(x: x2, y1: y1, y2: y2)
    }

    func drawPreviousButton(frame: CGRect) {
        let (x1, x2, y1, y2) = getDrawButtonBounds(frame)
        drawLineBetween(x: x1, y1: y1, y2: y2)
        moveToPoint(CGPoint(x: x2, y: y1))
        addLineToPoint(CGPoint(x: x2, y: y2))
        addLineToPoint(CGPoint(x: x1 + lineWidth, y: (y2 - y1) / 2 + y1))
        closePath()
    }

    func drawNextButton(frame: CGRect) {
        let (x1, x2, y1, y2) = getDrawButtonBounds(frame)
        drawLineBetween(x: x2, y1: y1, y2: y2)
        moveToPoint(CGPoint(x: x1, y: y1))
        addLineToPoint(CGPoint(x: x1, y: y2))
        addLineToPoint(CGPoint(x: x2 - lineWidth, y: (y2 - y1) / 2 + y1))
        closePath()
    }
}