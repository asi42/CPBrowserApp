//
//  ViewController.swift
//  CPBrowserApp
//
//  Created by Asaf h on 1/19/19.
//  Copyright © 2019 A h. All rights reserved.
//

import UIKit
import WebKit
import CoreData

class ViewController: UIViewController {
    private var dataProxy = DataProxy(dataContext: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    
    private var viewController:HistoryTVC?
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
    }
    
    func browse(newUrl:String) {
        if let url = URL(string: newUrl) {
            dataProxy.onNewBrowse(url: newUrl)
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

extension ViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        let url = textField.text
        guard url != nil, url!.count > 0 else {return true}
        browse(newUrl: url!)
        
        return true
    }
}

extension ViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        dataProxy.onCompletion()
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Error code" + error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(#function)
//        if (navigationAction.navigationType == .linkActivated){
//            decisionHandler(.cancel)
//        } else {
//            decisionHandler(.allow)
//        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print(#function)
        dataProxy.onRedirect(redirectUrl: webView.url!.absoluteString)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (viewController == nil) {
            viewController = (segue.destination as! HistoryTVC)
        }
        DispatchQueue.global(qos: .background).async {
            self.fetchData { (urlItems, error) in
                self.viewController!.urlItems = urlItems
            }
        }
    }
    
    
    func fetchData(completion: @escaping ([Url]?, Error?) -> Void) {
        
        let urlHistory = dataProxy.getUrlHistory()
        guard urlHistory != nil else {return}
        DispatchQueue.main.async {
            completion(urlHistory!, nil)
        }
    }
    
    
    
    
}

extension WKWebView {
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }
}

