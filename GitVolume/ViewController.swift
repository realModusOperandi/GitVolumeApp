//
//  ViewController.swift
//  GitVolume
//
//  Created by Liam Westby on 6/19/17.
//  Copyright © 2017 DEC Microcomputer Software, Inc. All rights reserved.
//

import Cocoa

class ViewController: NSViewController  {

    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var accountField: NSTextField!
    @IBOutlet weak var repoField: NSTextField!
    @IBOutlet weak var branchField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        statusLabel.stringValue = "Not monitoring"
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    fileprivate func getVolume(_ account: String, _ repo: String) {
        let url = "https://\(account).github.io/\(repo)/volume.properties"
        
        let requestURL: NSURL = NSURL(string:  url)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        urlRequest.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {(data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                DispatchQueue.main.async() {
                    self.statusLabel.stringValue = "Monitoring"
                }
                
            } else  {
                DispatchQueue.main.async() {
                    self.statusLabel.stringValue = "Volume not found"
                }
            }
            
            if let receivedData = data {
                print("Got data")
                let keyString = "volume = "
                let responseData = String(data: receivedData, encoding: String.Encoding.utf8)
                let lines = responseData?.components(separatedBy: .newlines)
                for line: String in lines! {
                    if line.starts(with: keyString) {
                        let volumeString = line.substring(from: (line.range(of: keyString)?.upperBound)!)
                        print("volume: \(volumeString)")
                        if let volume = Int(volumeString) {
                            print(volume)
                            self.setVolume(volume)
                        }
                    }
                }
            }
            
        }
        task.resume()
    }
    
    
    @IBAction func startMonitoring(_ sender: Any) {
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.monitor), userInfo: nil, repeats: true)
    }
    
    @objc func monitor() {
        print("monitor() called")
        let account = accountField.stringValue
        let repo = repoField.stringValue
        let branch = branchField.stringValue
        
        if account != "" && repo != "" {
            self.getVolume(account, repo)
        }
    }
    
    func setVolume(_ volume: Int) {
        print(volume)
        if volume > -1 && volume < 101 {
            NSSound.setSystemVolume(Float(volume)/Float(100.0))
        }
    }

}

