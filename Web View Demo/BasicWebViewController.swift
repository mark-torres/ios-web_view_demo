//
//  BasicWebViewController.swift
//  Web View Demo
//
//  Created by Marcos Torres on 7/25/17.
//  Copyright © 2017 HSoft Mobile. All rights reserved.
//

import UIKit

class BasicWebViewController: UIViewController, UITextFieldDelegate, UIWebViewDelegate {
	
	// MARK: - Variables
	
	@IBOutlet weak var textLocationUrl: UITextField!
	@IBOutlet weak var uiWebView: UIWebView!
	@IBOutlet weak var webToolBar: UIToolbar!
	@IBOutlet weak var loaderView: UIView!
	@IBOutlet weak var loaderSpinner: UIActivityIndicatorView!
	
	@IBOutlet weak var btnBackwd: UIBarButtonItem!
	@IBOutlet weak var btnFordwd: UIBarButtonItem!
	@IBOutlet weak var btnStop: UIBarButtonItem!
	@IBOutlet weak var btnRefresh: UIBarButtonItem!
	
	// MARK: - View Controller

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		// delegates
		textLocationUrl.delegate = self
		uiWebView.delegate = self
		//
		uiWebView.scrollView.bounces = false
		btnBackwd.isEnabled = false
		btnFordwd.isEnabled = false
		btnStop.isEnabled = false
		btnRefresh.isEnabled = false
		// add loader view and constraints with VFL
		// https://www.hackingwithswift.com/read/6/3/auto-layout-in-code-addconstraints-with-visual-format-language
		// https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html
		loaderView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(loaderView)
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-56-[loaderView]-44-|", options: [], metrics: nil, views: ["loaderView": loaderView]) )
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[loaderView]-0-|", options: [], metrics: nil, views: ["loaderView": loaderView]) )
		//
		let request = URLRequest( url: URL(string: "http://urdevel.mtorres.urstaging.com/test/webview.html")! )
		uiWebView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - UITextField Delegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == textLocationUrl {
			textLocationUrl.resignFirstResponder()
			let url = textField.text ?? ""
			loadUrl(fromString: url)
			return true
		}
		return false
	}
	
	// MARK: - WebView methods
	
	func loadUrl(fromString stringUrl: String) -> Void {
		guard let userUrl = URL(string: stringUrl) else {
			showAlert(withMessage: "The requested URL is not valid.", andTitle: "Error")
			return
		}
		let userRequest = URLRequest(url: userUrl)
		uiWebView.loadRequest(userRequest)
	}
	
	func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		let requestedUrl = request.url!
		let scheme = requestedUrl.scheme ?? ""
		// schemes must be whitelisted in Info.plist in LSApplicationQueriesSchemes array
		if scheme == "message" {
			let queryData = decodeHttpQuery(fromString: requestedUrl.query ?? "")
			print(queryData)
			let message = queryData["text"] ?? ""
			if !message.isEmpty {
				showAlert(withMessage: message, andTitle: "Message from UIWebView")
			}
			return false
		}
		return true
	}
	
	func webViewDidStartLoad(_ webView: UIWebView) {
		showLoader()
		btnStop.isEnabled = true
	}
	
	func webViewDidFinishLoad(_ webView: UIWebView) {
		hideLoader()
		btnStop.isEnabled = false
		btnRefresh.isEnabled = true
		if webView.canGoBack {
			btnBackwd.isEnabled = true
		}
		if webView.canGoForward {
			btnFordwd.isEnabled = true
		}
		let locationUrl = webView.request?.mainDocumentURL?.absoluteString ?? ""
		textLocationUrl.text = locationUrl
	}
	
	func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
		showAlert(withMessage: error.localizedDescription, andTitle: "Error loading page")
	}
	
	func showLoader() -> Void {
		loaderView.isHidden = false
		loaderSpinner.startAnimating()
	}
	
	func hideLoader() -> Void {
		loaderView.isHidden = true
		loaderSpinner.stopAnimating()
	}

	// MARK: - IB Actions
	
	@IBAction func tapBackwd(_ sender: Any) {
		if uiWebView.canGoBack {
			uiWebView.goBack()
		}
	}
	
	@IBAction func tapForwd(_ sender: Any) {
		if uiWebView.canGoForward {
			uiWebView.goForward()
		}
	}
	
	@IBAction func tapAction(_ sender: Any) {
		let actionSheet = UIAlertController(title: "Actions", message: nil, preferredStyle: .actionSheet)
		//
		let actionClose = UIAlertAction(title: "Close browser", style: .cancel) { (action) in
			self.dismiss(animated: true, completion: nil)
		}
		let actionGoogle = UIAlertAction(title: "Go to Google", style: .default) { (action) in
			self.loadUrl(fromString: "http://google.com")
		}
		let actionJs = UIAlertAction(title: "Run JS code", style: .default) { (action) in
			self.uiWebView.stringByEvaluatingJavaScript(from: "document.bgColor = '#F0F8FF';")
		}
		actionSheet.addAction(actionJs)
		actionSheet.addAction(actionGoogle)
		actionSheet.addAction(actionClose)
		//
		if runningOnTablet() {
			actionSheet.popoverPresentationController?.sourceView = webToolBar
			actionSheet.popoverPresentationController?.sourceRect = webToolBar.bounds
		}
		present(actionSheet, animated: true, completion: nil)
	}
	
	@IBAction func tapStop(_ sender: Any) {
		if uiWebView.isLoading {
			uiWebView.stopLoading()
		}
	}
	
	@IBAction func tapRefresh(_ sender: Any) {
		uiWebView.reload()
	}
	
}
