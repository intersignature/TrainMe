//
//  CourseVideoTableViewCell.swift
//  TrainMe
//
//  Created by Sirichai Binchai on 19/4/2562 BE.
//  Copyright © 2562 Sirichai Binchai. All rights reserved.
//

import UIKit
import WebKit
import YouTubePlayer

class CourseVideoTableViewCell: UITableViewCell {


    @IBOutlet weak var courseVideoView: YouTubePlayerView!
    weak var courseVideoWebView: WKWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func getVideo(videoCode: String) {
        
        let playerVars = ["controls": "1", "playsinline": "1", "autohide": "1", "showinfo": "1", "autoplay": "0", "fs": "1", "rel": "0", "loop": "0", "enablejsapi": "1", "modestbranding": "1"]
        
        courseVideoView.playerVars = playerVars as YouTubePlayerView.YouTubePlayerParameters
        
        courseVideoView.loadVideoID(videoCode)
//        let webV:UIWebView = UIWebView(frame: CGRect(x: 0, y: 0, width: courseVideoView.bounds.width, height: courseVideoView.bounds.height))
//        webV.loadRequest(URLRequest(url: URL(string: "https://www.youtube.com/embed/\(videoCode)")!))
//        webV.delegate = self;
//        self.courseVideoView.addSubview(webV)
    }
//    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
//         print("Webview fail with error \(error)");
//    }
//
//    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        return true
//    }
//
//    func webViewDidStartLoad(_ webView: UIWebView) {
//        print("Webview started Loading")
//    }
//    func webViewDidFinishLoad(_ webView: UIWebView) {
//         print("Webview did finish load")
//    }
}
