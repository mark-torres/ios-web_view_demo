//
//  UIVCExtension.swift
//  Web View Demo
//
//  Created by Marcos Torres on 7/25/17.
//  Copyright © 2017 HSoft Mobile. All rights reserved.
//

import UIKit

extension UIViewController {
	
	func showAlert(withMessage message: String, andTitle title: String) -> Void {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(okAction)
		present(alert, animated: true, completion: nil)
	}
	
	func runningOnTablet() -> Bool {
		return (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
	}
}
