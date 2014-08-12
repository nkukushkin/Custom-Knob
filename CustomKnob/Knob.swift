//
//  Knob.swift
//  CustomKnob
//
//  Created by Nikita Kukushkin on 06/08/2014.
//  Copyright (c) 2014 Nikita Kukushkin. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable public class Knob: UIControl {
    
    private let renderer = Renderer()
    private let gestureRecognizer: RotationGestureRecognizer!
    
    // MARK: API
    
    /**
     Contains a Boolean value indicating whether changes in the value of the knob
     generate continuous update events. The default value is `true`.
     */
    @IBInspectable public var continuous = true
    
    /**
     The minimum value of the knob. Defaults to 0.0.
     */
    @IBInspectable public var minimumValue: Float = 0.0
    
    /**
     The maximum value of the knob. Defaults to 1.0.
     */
    @IBInspectable public var maximumValue: Float = 1.0
    
    /**
     Contains the current value.
     */
    public private(set) var value: Float = 0.0
    
    /**
     Sets the value the knob should represent, with optional animation of the change.
     */
    public func setValue(value: Float, animated: Bool = false) {
        if self.value != value {
            self.value = min(maximumValue, max(minimumValue, value))
            renderer.setPointerAngle(angleForValue(self.value), animated: animated)
        }
    }
    
    // MARK: UIView
    
    override public func tintColorDidChange() {
        renderer.color = tintColor
    }
    
    override public func prepareForInterfaceBuilder() {
        renderUI()
    }
    
    // MARK: Lifecycle
    
    private func renderUI() {
        renderer.color = tintColor
        renderer.updateWithBounds(bounds)
        
        layer.addSublayer(renderer.trackLayer)
        layer.addSublayer(renderer.pointerLayer)
    }
    
    required public init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        gestureRecognizer = RotationGestureRecognizer(target: self, action: "handleGesture:")
        addGestureRecognizer(gestureRecognizer)
        renderUI()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        gestureRecognizer = RotationGestureRecognizer(target: self, action: "handleGesture:")
        addGestureRecognizer(gestureRecognizer)
        renderUI()
    }
    
}

// MARK: - Renderer extension

public extension Knob {
    
    // MARK: API
    
    /**
     Specifies the angle of the start of the knob control track. Defaults to -11π/8.
     */
    public var startAngle: CGFloat {
        get {
            return renderer.startAngle
        }
        set {
            renderer.startAngle = newValue
        }
    }
    
    /**
     Specifies the end angle of the knob control track. Defaults to 3π/8.
     */
    public var endAngle: CGFloat {
        get {
            return renderer.endAngle
        }
        set {
            renderer.endAngle = newValue
        }
    }
    
    /**
     Specifies the width in points of the knob control track. Defaults to 2.0.
     */
    @IBInspectable public var lineWidth: CGFloat {
        get {
            return renderer.lineWidth
        }
        set {
            renderer.lineWidth = newValue
        }
    }
    
    /**
     Specifies the length in points of the pointer on the knob. Defaults to 6.0.
     */
    @IBInspectable public var pointerLength: CGFloat {
        get {
            return renderer.pointerLength
        }
        set {
            renderer.pointerLength = newValue
        }
    }
    
    // MARK: Renderer
    
    private class Renderer {
        
        var color: UIColor = UIColor.blackColor() {
            didSet {
                trackLayer.strokeColor = color.CGColor
                pointerLayer.strokeColor = color.CGColor
            }
        }
        var lineWidth: CGFloat = 2 {
            didSet {
                trackLayer.lineWidth = lineWidth
                pointerLayer.lineWidth = lineWidth
                updateTrackShape()
                updatePointerShape()
            }
        }
        
        // MARK: Track Layer
        
        let trackLayer: CAShapeLayer = {
            var layer = CAShapeLayer.init()
            layer.fillColor = UIColor.clearColor().CGColor
            return layer
            }()
        
        var startAngle: CGFloat = -CGFloat(M_PI) * 11 / 8.0 {
            didSet {
                updateTrackShape()
            }
        }
        var endAngle: CGFloat = CGFloat(M_PI) * 3 / 8.0 {
            didSet {
                updateTrackShape()
            }
        }
        
        // MARK: Pointer Layer
        
        let pointerLayer: CAShapeLayer = {
            var layer = CAShapeLayer.init()
            layer.fillColor = UIColor.clearColor().CGColor
            return layer
            }()
        
        var pointerAngle: CGFloat = CGFloat(M_PI) * 11 / 8.0
        var pointerLength: CGFloat = 6 {
            didSet {
                updateTrackShape()
                updatePointerShape()
            }
        }
        
        func setPointerAngle(angle: CGFloat, animated: Bool = false) {
            CATransaction()
            CATransaction.setDisableActions(true)
            pointerLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
            if animated {
                let midAngle = (max(pointerAngle, angle) - min(pointerAngle, angle)) / 2 + min(pointerAngle, angle)
                let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
                animation.duration = 0.3
                animation.values = [pointerAngle, midAngle, angle]
                animation.keyTimes = [0, 0.5, 1.0]
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                
                pointerLayer.addAnimation(animation, forKey: nil)
            }
            CATransaction.commit()
            pointerAngle = angle
        }
        
        // MARK: Update Logic
        
        func updateTrackShape() {
            let center = CGPoint(x: trackLayer.bounds.width / 2, y: trackLayer.bounds.height / 2)
            let offset = max(pointerLength, lineWidth / 2)
            let radius = min(trackLayer.bounds.width, trackLayer.bounds.height) / 2 - offset
            let ring = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            trackLayer.path = ring.CGPath
        }
        
        func updatePointerShape() {
            let pointer = UIBezierPath()
            pointer.moveToPoint(CGPoint(x: pointerLayer.bounds.width - pointerLength - lineWidth/2, y: pointerLayer.bounds.height / 2))
            pointer.addLineToPoint(CGPoint(x: pointerLayer.bounds.width, y: pointerLayer.bounds.height / 2))
            
            pointerLayer.path = pointer.CGPath
        }
        
        func updateWithBounds(bounds: CGRect) {
            trackLayer.bounds = bounds
            trackLayer.position = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
            updateTrackShape()
            
            pointerLayer.bounds = trackLayer.bounds
            pointerLayer.position = trackLayer.position
            updatePointerShape()
        }
        
        // MARK: Lifecycle
        
        init() {
            trackLayer.lineWidth = lineWidth
            pointerLayer.lineWidth = lineWidth
            trackLayer.strokeColor = color.CGColor
            pointerLayer.strokeColor = color.CGColor
        }
        
    }
    
}

// MARK: - Rotation Gesture Recogniser extension

private extension Knob {
    
    // note the use of dynamic, because calling
    // private swift selectors(@ gestureRec target:action:!) gives an exception
    dynamic func handleGesture(gesture: RotationGestureRecognizer) {
        let midPointAngle = (2 * CGFloat(M_PI) + startAngle - endAngle) / 2 + endAngle
        
        var boundedAngle = gesture.touchAngle
        if boundedAngle > midPointAngle {
            boundedAngle -= CGFloat(2 * M_PI)
        }
        else if boundedAngle < (midPointAngle - CGFloat(2 * M_PI)) {
            boundedAngle += CGFloat(2 * M_PI)
        }
        
        boundedAngle = min(endAngle, max(startAngle, boundedAngle))
        
        setValue(valueForAngle(boundedAngle))
        
        if continuous {
            sendActionsForControlEvents(.ValueChanged)
        }
        else {
            // inference didn't work for .Cancelled for some reason on Beta5
            if gesture.state == .Ended || gesture.state == UIGestureRecognizerState.Cancelled {
                sendActionsForControlEvents(.ValueChanged)
            }
        }
    }
    
    // note the need of importing
    // <UIKit/UIGestureRecognizerSubclass.h> in bridging header
    class RotationGestureRecognizer: UIPanGestureRecognizer {
        
        var touchAngle: CGFloat = 0
        
        // MARK: UIGestureRecognizerSubclass
        
        override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
            super.touchesBegan(touches, withEvent: event)
            updateTouchAngleWithTouches(touches)
        }
        
        override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
            super.touchesMoved(touches, withEvent: event)
            updateTouchAngleWithTouches(touches)
        }
        
        func updateTouchAngleWithTouches(touches: NSSet!) {
            let touch = touches.anyObject() as UITouch
            let touchPoint = touch.locationInView(view)
            
            touchAngle = calculateAngleToPoint(touchPoint)
        }
        
        func calculateAngleToPoint(point: CGPoint) -> CGFloat {
            let centerOffset = CGPoint(x: point.x - CGRectGetMidX(view.bounds), y: point.y - CGRectGetMidY(view.bounds))
            return atan2(centerOffset.y, centerOffset.x)
        }
        
        // MARK: Lifecycle
        
        override init(target: AnyObject!, action: Selector) {
            super.init(target: target, action: action)
            maximumNumberOfTouches = 1
            minimumNumberOfTouches = 1
        }
    }
}

// MARK: - Utilities extenstion

private extension Knob {
    
    // MARK: Value/Angle conversion
    
    func valueForAngle(angle: CGFloat) -> Float {
        let angleRange = Float(endAngle - startAngle)
        let valueRange = maximumValue - minimumValue
        return Float(angle - startAngle) / angleRange * valueRange + minimumValue
    }
    
    func angleForValue(value: Float) -> CGFloat {
        let angleRange = endAngle - startAngle
        let valueRange = CGFloat(maximumValue - minimumValue)
        return CGFloat(self.value - minimumValue) / valueRange * angleRange + startAngle
    }

}