//
//  HelpTransitionAnimator.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 11/28/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

final class HelpTransitionAnimator: NSObject {
    
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
    
    func shapeLayer(forPath path: CGPath, at position: CGPoint) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.position = position
        return shapeLayer
    }
}

// MARK: UIViewControllerAnimatedTransitioning

extension HelpTransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        self.storedContext = transitionContext
        self.maxRadius = max(fromVC.view.frame.height, fromVC.view.frame.width)
        let circleMask = shapeLayer(forPath: circlePath, at: originPoint)

        if operation == .push {
            transitionContext.containerView.addSubview(toVC.view)
            toVC.view.layer.mask = circleMask
        } else {
            transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            fromVC.view.layer.mask = circleMask
        }
        
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        circleMask.add(animation, forKey: nil)
    }
}

// MARK: CAAnimationDelegate

extension HelpTransitionAnimator: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let context = storedContext {
            context.completeTransition(!context.transitionWasCancelled)
            let toVC = context.viewController(forKey: .to)!
            toVC.view.layer.mask = nil
        }
        storedContext = nil
    }
}
