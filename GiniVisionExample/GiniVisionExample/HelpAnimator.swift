//
//  HelpAnimator.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/28/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

final class HelpAnimator: NSObject {
    
    let animationDuration = 0.65
    var maxRadius: CGFloat = 0.0
    var circleScale: CGFloat = 100.0
    var operation: UINavigationControllerOperation = .push
    var originPoint: CGPoint = .zero
    weak var storedContext: UIViewControllerContextTransitioning?
    
    var animation: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        animation.toValue = animateToValue
        animation.duration = animationDuration
        animation.delegate = self
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        return animation
    }
    
    var animateToValue: NSValue {
        if operation == .push {
            return NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(0.0, 0, 0.0),
                                                              CATransform3DMakeScale(circleScale, circleScale, 1.0)))
        } else {
            return NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(0.0, 0, 0.0),
                                                              CATransform3DMakeScale(1 / circleScale,
                                                                                     1 / circleScale,
                                                                                     1.0)))
        }
    }
    
    var circlePath: CGPath {
        if operation == .push {
            return UIBezierPath(arcCenter: CGPoint(x: 0, y: 0),
                                radius: CGFloat(maxRadius / circleScale),
                                startAngle: CGFloat(0),
                                endAngle: CGFloat(Double.pi * 2), clockwise: true).cgPath
        } else {
            return UIBezierPath(arcCenter: CGPoint(x: 0, y: 0),
                                radius: CGFloat(maxRadius),
                                startAngle: CGFloat(0),
                                endAngle: CGFloat(Double.pi * 2), clockwise: true).cgPath
        }
    }
    
    var shapeLayer: CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath
        shapeLayer.fillColor = UIColor.green.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 3.0
        shapeLayer.position = originPoint
        return shapeLayer
    }
}

extension HelpAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        storedContext = transitionContext
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        maxRadius = max(fromVC.view.frame.height, fromVC.view.frame.width)
        if operation == .push {
            transitionContext.containerView.addSubview(toVC.view)
        } else {
            transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        }
        
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        
        let shapeLayer = self.shapeLayer
        if operation == .push {
            toVC.view.layer.mask = shapeLayer
        } else {
            fromVC.view.layer.mask = shapeLayer
        }
        
        shapeLayer.add(animation, forKey: nil)
    }
}

extension HelpAnimator: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let context = storedContext {
            context.completeTransition(!context.transitionWasCancelled)
            let toVC = context.viewController(forKey: .to)!
            toVC.view.layer.mask = nil
        }
        storedContext = nil
    }
}
