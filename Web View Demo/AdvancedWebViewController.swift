//
//  AdvancedWebViewController.swift
//  Web View Demo
//
//  Created by Marcos Torres on 7/25/17.
//  Copyright © 2017 HSoft Mobile. All rights reserved.
//

import UIKit
import WebKit

class AdvancedWebViewController: UIViewController, UITextFieldDelegate, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate {
	
	// MARK: - Variables
	
	@IBOutlet weak var textLocationUrl: UITextField!
	@IBOutlet weak var webToolBar: UIToolbar!
	@IBOutlet weak var loaderView: UIView!
	@IBOutlet weak var loaderSpinner: UIActivityIndicatorView!
	
	@IBOutlet weak var btnBackwd: UIBarButtonItem!
	@IBOutlet weak var btnFordwd: UIBarButtonItem!
	@IBOutlet weak var btnStop: UIBarButtonItem!
	@IBOutlet weak var btnRefresh: UIBarButtonItem!
	
	var wkWebView: WKWebView!
	
	// MARK: - View Controller

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		btnBackwd.isEnabled = false
		btnFordwd.isEnabled = false
		btnStop.isEnabled = false
		btnRefresh.isEnabled = false
		loaderView.isHidden = true
		loaderSpinner.stopAnimating()
		// add WkWebView and its constraints
		// https://developer.apple.com/documentation/webkit/wkwebview
		let wkConfig = WKWebViewConfiguration()
		wkConfig.userContentController.add(self, name: "jsBridge")
		wkConfig.allowsInlineMediaPlayback = true
		wkWebView = WKWebView(frame: self.view.frame, configuration: wkConfig)
		wkWebView.allowsBackForwardNavigationGestures = false
		wkWebView.translatesAutoresizingMaskIntoConstraints = false
		
		self.view.addSubview(wkWebView)
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-56-[wkWebView]-44-|", options: [], metrics: nil, views: ["wkWebView": wkWebView]) )
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[wkWebView]-0-|", options: [], metrics: nil, views: ["wkWebView": wkWebView]) )
		// add loader view and constraints with VFL
		// https://www.hackingwithswift.com/read/6/3/auto-layout-in-code-addconstraints-with-visual-format-language
		// https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html
		loaderView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(loaderView)
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-56-[loaderView]-44-|", options: [], metrics: nil, views: ["loaderView": loaderView]) )
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[loaderView]-0-|", options: [], metrics: nil, views: ["loaderView": loaderView]) )
		// delegates
		textLocationUrl.delegate = self
		wkWebView.uiDelegate = self
		wkWebView.navigationDelegate = self
		//
		let homeUrl = "http://urdevel.mtorres.urstaging.com/test/webview.html"
		loadUrl(fromString: homeUrl)
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
		let cleanString = stringUrl.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !cleanString.isEmpty else {
			showAlert(withMessage: "The requested URL is empty.", andTitle: "Error")
			return
		}
		guard let urlToLoad = URL(string: cleanString) else {
			showAlert(withMessage: "The requested URL is not valid.", andTitle: "Error")
			return
		}
		let urlRequest = URLRequest(url: urlToLoad)
		wkWebView.load(urlRequest)
	}
	
	func showLoader() -> Void {
		loaderView.isHidden = false
		loaderSpinner.startAnimating()
	}
	
	func hideLoader() -> Void {
		loaderView.isHidden = true
		loaderSpinner.stopAnimating()
	}
	
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
	}
	
	func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
		let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
		let actionOk = UIAlertAction(title: "OK", style: .default) { (action) in
			completionHandler()
		}
		alert.addAction(actionOk)
		present(alert, animated: true, completion: nil)
	}
	
	func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
		let confirm = UIAlertController(title: nil, message: message, preferredStyle: .alert)
		let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
			completionHandler(false)
		}
		let actionOk = UIAlertAction(title: "OK", style: .default) { (action) in
			completionHandler(true)
		}
		confirm.addAction(actionOk)
		confirm.addAction(actionCancel)
		present(confirm, animated: true, completion: nil)
	}
	
	func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
		let prompt = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
		// add text field
		prompt.addTextField { (textField) in
			textField.text = defaultText
		}
		// add actions
		let actionOk = UIAlertAction(title: "OK", style: .default) { (action) in
			let input = prompt.textFields?[0].text
			completionHandler(input)
		}
		let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
			completionHandler(nil)
		}
		prompt.addAction(actionOk)
		prompt.addAction(actionCancel)
		present(prompt, animated: true, completion: nil)
	}
	
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		showLoader()
		btnRefresh.isEnabled = false
		btnStop.isEnabled = true
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		hideLoader()
		btnRefresh.isEnabled = true
		btnStop.isEnabled = false
		if wkWebView.canGoBack {
			btnBackwd.isEnabled = true
		}
		if wkWebView.canGoForward {
			btnFordwd.isEnabled = true
		}
		let locationUrl = wkWebView.url?.absoluteString
		textLocationUrl.text = locationUrl
	}
	
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		hideLoader()
		btnRefresh.isEnabled = true
		btnStop.isEnabled = false
	}
	
	// MARK: - IB Actions
	
	@IBAction func tapBackwd(_ sender: Any) {
		if wkWebView.canGoBack {
			wkWebView.goBack()
		}
	}
	
	@IBAction func tapForwd(_ sender: Any) {
		if wkWebView.canGoForward {
			wkWebView.goForward()
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
		if wkWebView.isLoading {
			wkWebView.stopLoading()
		}
	}
	
	@IBAction func tapRefresh(_ sender: Any) {
		if !wkWebView.isLoading {
			wkWebView.reload()
		}
	}
}
