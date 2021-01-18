//
//  JSNavigationBarController.swift
//  JSNavigationController
//
//  Created by Julien Sagot on 14/05/16.
//  Copyright © 2016 Julien Sagot. All rights reserved.
//

import AppKit

open class JSNavigationBarController: JSViewControllersStackManager {
	open var viewControllers: [NSViewController] = []
	open weak var contentView: NSView?

	// MARK: - Initializers
	public init(view: NSView) {
		contentView = view
	}

	// MARK: - Default animations
	open func defaultPushAnimation() -> AnimationBlock {
		return { [weak self] (_, _) in
			let containerViewBounds = self?.contentView?.bounds ?? .zero

			let slideToLeftTransform = CATransform3DMakeTranslation(-containerViewBounds.width / 2, 0, 0)
			let slideToLeftAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
			slideToLeftAnimation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
			slideToLeftAnimation.toValue = NSValue(caTransform3D: slideToLeftTransform)
			slideToLeftAnimation.duration = 0.25
			slideToLeftAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
			slideToLeftAnimation.fillMode = CAMediaTimingFillMode.forwards
			slideToLeftAnimation.isRemovedOnCompletion = false

			let slideFromRightTransform = CATransform3DMakeTranslation(containerViewBounds.width / 2, 0, 0)
			let slideFromRightAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
			slideFromRightAnimation.fromValue = NSValue(caTransform3D: slideFromRightTransform)
			slideFromRightAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
			slideFromRightAnimation.duration = 0.25
			slideFromRightAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
			slideFromRightAnimation.fillMode = CAMediaTimingFillMode.forwards
			slideFromRightAnimation.isRemovedOnCompletion = false

			let fadeInAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
			fadeInAnimation.fromValue = 0.0
			fadeInAnimation.toValue = 1.0
			fadeInAnimation.duration = 0.25
			fadeInAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
			fadeInAnimation.fillMode = CAMediaTimingFillMode.forwards
			fadeInAnimation.isRemovedOnCompletion = false

			let fadeOutAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
			fadeOutAnimation.fromValue = 1.0
			fadeOutAnimation.toValue = 0.0
			fadeOutAnimation.duration = 0.25
			fadeOutAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
			fadeOutAnimation.fillMode = CAMediaTimingFillMode.forwards
			fadeOutAnimation.isRemovedOnCompletion = false

			return ([slideToLeftAnimation, fadeOutAnimation], [slideFromRightAnimation, fadeInAnimation])
		}
	}

	open func defaultPopAnimation() -> AnimationBlock {
		return { [weak self] (_, _) in
			let containerViewBounds = self?.contentView?.bounds ?? .zero

			let slideToRightTransform = CATransform3DMakeTranslation(-containerViewBounds.width / 2, 0, 0)
			let slideToRightAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
			slideToRightAnimation.fromValue = NSValue(caTransform3D: slideToRightTransform)
			slideToRightAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
			slideToRightAnimation.duration = 0.25
			slideToRightAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
			slideToRightAnimation.fillMode = CAMediaTimingFillMode.forwards
			slideToRightAnimation.isRemovedOnCompletion = false

			let slideToRightFromCenterTransform = CATransform3DMakeTranslation(containerViewBounds.width / 2, 0, 0)
			let slideToRightFromCenterAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
			slideToRightFromCenterAnimation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
			slideToRightFromCenterAnimation.toValue = NSValue(caTransform3D: slideToRightFromCenterTransform)
			slideToRightFromCenterAnimation.duration = 0.35
			slideToRightFromCenterAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
			slideToRightFromCenterAnimation.fillMode = CAMediaTimingFillMode.forwards
			slideToRightFromCenterAnimation.isRemovedOnCompletion = false

			let fadeInAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
			fadeInAnimation.fromValue = 0.0
			fadeInAnimation.toValue = 1.0
			fadeInAnimation.duration = 0.25
			fadeInAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
			fadeInAnimation.fillMode = CAMediaTimingFillMode.forwards
			fadeInAnimation.isRemovedOnCompletion = false

			let fadeOutAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
			fadeOutAnimation.fromValue = 1.0
			fadeOutAnimation.toValue = 0.0
			fadeOutAnimation.duration = 0.25
			fadeOutAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
			fadeOutAnimation.fillMode = CAMediaTimingFillMode.forwards
			fadeOutAnimation.isRemovedOnCompletion = false

			return ([slideToRightFromCenterAnimation, fadeOutAnimation], [slideToRightAnimation, fadeInAnimation])
		}
	}
}
