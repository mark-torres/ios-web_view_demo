//
//  BasicWebViewController.swift
//  Web View Demo
//
//  Created by Marcos Torres on 7/25/17.
//  Copyright © 2017 HSoft Mobile. All rights reserved.
//

import UIKit

class BasicWebViewController: UIViewController {
	
	// MARK: - Variables
	
	@IBOutlet weak var textLocationUrl: UITextField!
	@IBOutlet weak var uiWebView: UIWebView!
	@IBOutlet weak var webProgress: UIProgressView!
	
	// MARK: - View Controller

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - WebView Delegate

	// MARK: - IB Actions
	
	@IBAction func tapGo(_ sender: UIButton) {
		let locationUrl = textLocationUrl.text!
		showAlert(withMessage: locationUrl, andTitle: "Location URL")
	}
	
	@IBAction func tapBackwd(_ sender: Any) {
	}
	
	@IBAction func tapForwd(_ sender: Any) {
	}
	
	@IBAction func tapAction(_ sender: Any) {
	}
	
	@IBAction func tapStop(_ sender: Any) {
	}
	
	@IBAction func tapRefresh(_ sender: Any) {
	}
	
}
