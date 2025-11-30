//
//  Animations.swift
//  FLEXXFIT
//
//  Created by Riccardo Washington on 2/23/19.
//  Copyright © 2019 Riccardo Washington. All rights reserved.
//

import UIKit

extension UIView {
    func bounce(duration: CFTimeInterval) {
        let a: CAKeyframeAnimation = {
            func nsNumber(n: Double) -> NSNumber { return NSNumber(value: n) }
            let values: [Double] = [1.0, 0.7, 1.0]
            let keyTimes: [Double] = [0.0, 0.5, 1.0]
            $0.keyPath = "transform.scale"
            $0.values = values.map { $0 }
            $0.keyTimes = keyTimes.map(nsNumber)
            $0.duration = duration
            $0.isRemovedOnCompletion = true
            return $0
        } (CAKeyframeAnimation())
        self.layer.add(a, forKey: "bounce")
    }
    
    func wiggle(duration: CFTimeInterval) {
        let a: CAKeyframeAnimation = {
            func nsNumber(n: Double) -> NSNumber { return NSNumber(value: n) }
            let values: [Double] = [0, 0.2, 0, -0.2, 0]
            let keyTimes: [Double] = [0.0, 0.25, 0.5, 0.75, 1.0]
            $0.keyPath = "position.x"
            $0.values = values.map { $0 }
            $0.keyTimes = keyTimes.map(nsNumber)
            $0.duration = duration
            $0.isRemovedOnCompletion = true
            return $0
        } (CAKeyframeAnimation())
        self.layer.add(a, forKey: "bounce")
        
    }
    
    func cameraAttentionAnimation() {
        // Simple but noticeable camera animation with pulse ring
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.3
        pulseAnimation.duration = 1.0
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // Add subtle glow
        self.layer.shadowColor = UIColor.goatBlue.cgColor
        self.layer.shadowRadius = 8.0
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 0.6
        
        // Add animations
        self.layer.add(pulseAnimation, forKey: "cameraAttentionPulse")
        
        // Add pulse ring effect
        addPulseRingEffect()
    }
    
    func stopCameraAttentionAnimation() {
        // Remove attention animation
        self.layer.removeAnimation(forKey: "cameraAttentionPulse")
        
        // Remove pulse ring
        if let ringLayer = self.layer.value(forKey: "pulseRingLayer") as? CAShapeLayer {
            ringLayer.removeFromSuperlayer()
            self.layer.setValue(nil, forKey: "pulseRingLayer")
        }
        
        // Reset visual properties
        self.layer.shadowOpacity = 0.0
        self.transform = CGAffineTransform.identity
    }
    
    func cameraShutterAnimation(completion: @escaping () -> Void = {}) {
        // Create a camera shutter effect when tapped
        let scaleDown = CABasicAnimation(keyPath: "transform.scale")
        scaleDown.fromValue = 1.0
        scaleDown.toValue = 0.85
        scaleDown.duration = 0.1
        scaleDown.fillMode = .forwards
        scaleDown.isRemovedOnCompletion = false
        
        let scaleUp = CABasicAnimation(keyPath: "transform.scale")
        scaleUp.fromValue = 0.85
        scaleUp.toValue = 1.0
        scaleUp.duration = 0.15
        scaleUp.beginTime = 0.1
        scaleUp.fillMode = .forwards
        scaleUp.isRemovedOnCompletion = false
        
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.fromValue = 1.0
        flash.toValue = 0.7
        flash.duration = 0.05
        flash.autoreverses = true
        
        let group = CAAnimationGroup()
        group.animations = [scaleDown, scaleUp, flash]
        group.duration = 0.25
        group.fillMode = .forwards
        group.isRemovedOnCompletion = true
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.layer.add(group, forKey: "cameraShutter")
        CATransaction.commit()
    }
    
    private func addPulseRingEffect() {
        // Create a pulsing ring around the camera button
        let ringLayer = CAShapeLayer()
        let ringSize: CGFloat = max(bounds.width, bounds.height) + 16
        let ringRect = CGRect(x: -ringSize/2, y: -ringSize/2, width: ringSize, height: ringSize)
        let ringPath = UIBezierPath(ovalIn: ringRect)
        ringLayer.path = ringPath.cgPath
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.strokeColor = UIColor.goatBlue.withAlphaComponent(0.7).cgColor
        ringLayer.lineWidth = 2.0
        ringLayer.opacity = 0.0
        
        // Position ring layer centered on this view
        ringLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        layer.insertSublayer(ringLayer, at: 0)
        
        // Ring pulse animation
        let ringPulse = CABasicAnimation(keyPath: "transform.scale")
        ringPulse.fromValue = 0.8
        ringPulse.toValue = 1.8
        ringPulse.duration = 1.0
        ringPulse.repeatCount = .infinity
        
        let ringFade = CABasicAnimation(keyPath: "opacity")
        ringFade.fromValue = 1.0
        ringFade.toValue = 0.0
        ringFade.duration = 1.0
        ringFade.repeatCount = .infinity
        
        let ringGroup = CAAnimationGroup()
        ringGroup.animations = [ringPulse, ringFade]
        ringGroup.duration = 1.0
        ringGroup.repeatCount = .infinity
        
        ringLayer.add(ringGroup, forKey: "pulseRing")
        
        // Store reference to ring layer for cleanup
        self.layer.setValue(ringLayer, forKey: "pulseRingLayer")
    }
}
