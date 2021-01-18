//
//  JSViewController.swift
//  JSNavigationController
//
//  Created by Julien Sagot on 02/06/16.
//  Copyright © 2016 Julien Sagot. All rights reserved.
//

import AppKit

open class JSViewController: NSViewController, JSNavigationBarViewControllerProvider {

	private static let navigationControllerPushIdentifier = "navigationControllerPush"
	private static let navigationBarViewControllerIdentifier = "navigationBarViewController"

	open private(set) var destinationViewController: NSViewController?
	open private(set) var destinationViewControllers: [String: NSViewController] = [:]
	open var navigationBarVC: NSViewController?
	open weak var navigationController: JSNavigationController?

	open func navigationBarViewController() -> NSViewController {
		guard let navigationBarVC = navigationBarVC else { fatalError("You must set the navigationBar view controller") }
		return navigationBarVC
	}

	// MARK: - View Lifecycle
	open override func awakeFromNib() {
		if type(of: self).instancesRespond(to: #selector(NSViewController.awakeFromNib)) {
			super.awakeFromNib()
		}
		setupSegues()
	}

	// MARK: - Segues
	private func setupSegues() {
		guard let segues = value(forKey: "segueTemplates") as? [NSObject] else { return }
		for segue in segues {
			if let id = segue.value(forKey: "identifier") as? String {
				performSegue(withIdentifier: id, sender: self)
			}
		}
	}

	open override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		guard let segueIdentifier = segue.identifier else { return }

		switch segueIdentifier {
		case JSViewController.navigationBarViewControllerIdentifier:
			navigationBarVC = segue.destinationController as? NSViewController
		default:
			if segueIdentifier.contains(JSViewController.navigationControllerPushIdentifier) {
				if segueIdentifier.count > JSViewController.navigationControllerPushIdentifier.count && segueIdentifier.contains("#") {
					if let key = segueIdentifier.split(separator: "#").map({ String($0) }).last {
						destinationViewControllers[key] = segue.destinationController as? NSViewController
					}
				} else {
					destinationViewController = segue.destinationController as? NSViewController
				}
			}
		}
	}
}
