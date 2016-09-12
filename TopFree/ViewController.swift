//
//  ViewController.swift
//  TopFree
//
//  Created by Thales Toniolo on 9/29/15.
//  Copyright © 2015 Flameworks. All rights reserved.
//

import UIKit

// MARK: - Class Declaration
class ViewController: UIViewController {
	// MARK: - Public Objects
	
	// MARK: - Private Objects
	var session: NSURLSession?
	
	// MARK: - Interface Objects
	@IBOutlet weak var appIcoImageView: UIImageView!
	@IBOutlet weak var appTitleLabel: UILabel!

	// MARK: - Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		self.session = NSURLSession(configuration: sessionConfig)

		let url: NSURL = NSURL(string: "https://itunes.apple.com/br/rss/topfreeapplications/limit=1/json")!
		let task = self.session!.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
			if (error == nil) {
//				let retStr: String = String(data: data!, encoding: NSUTF8StringEncoding)!
//				print(retStr)
				if let appName = self.getTopFreeName(data!) {
					dispatch_async(dispatch_get_main_queue(), {
						self.appTitleLabel.text = appName
					})
				}
				if let appImageURL = self.getTopFreeImageURL(data!) {
					self.downloadImage(appImageURL)
				}
			} else {
				print("error")
			}
		})
		task.resume()
	}
	
	// MARK: - Private Methods
	func getTopFreeName(data: NSData) -> String? {
		var retStr: String? = nil
		do {
			let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
			if let feed = json["feed"] as? [String: AnyObject] {
				if let entry = feed["entry"] as? [String: AnyObject] {
					if let name = entry["im:name"] as? [String: AnyObject] {
						if let label = name["label"] as? String {
							retStr = label
						}
					}
				}
			}
		} catch {
			print("Erro no parser JSON")
			return nil
		}

		return retStr
	}

	func getTopFreeImageURL(data: NSData) -> String? {
		var retStr: String? = nil
		do {
			let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
			if let feed = json["feed"] as? [String: AnyObject] {
				if let entry = feed["entry"] as? [String: AnyObject] {
					print(entry)
					if let name = entry["im:image"] as? [AnyObject] {
						if let label = name[0]["label"] as? String {
							retStr = label
						}
					}
				}
			}
		} catch {
			print("Erro no parser JSON")
			return nil
		}
		
		return retStr
	}

	func downloadImage(imgURL: String) {
		let url = NSURL(string: imgURL)!
		let imageSession = NSURLSession.sharedSession()
		let imgTask = imageSession.downloadTaskWithURL(url) { (url, response, error) -> Void in
			if (error == nil) {
				if let imageData = NSData(contentsOfURL: url!) {
					dispatch_async(dispatch_get_main_queue(), {
						self.appIcoImageView.image = UIImage(data: imageData)
					})
				}
			} else {
				print("Erro ao baixar imagem")
			}
		}
		imgTask.resume()
	}

	// MARK: - Delegate/Datasource

	// MARK: - Navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "mySegue") {
			//...
		}
	}
	
	// MARK: - Death Cycle
	override func viewDidDisappear(animated: Bool) {
		//...
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
