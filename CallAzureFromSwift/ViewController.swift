//
//  ViewController.swift
//  CallAzureFromSwift
//
//  Created by G Bear on 2020-02-27.
//  Copyright © 2020 Rooh Bear Corporation. All rights reserved.
//

import UIKit


class ViewController: UIViewController
{
    let COGSVCS_CLIENTURL = "https://northcentralus.api.cognitive.microsoft.com/vision/v2.1/analyze?visualFeatures=Categories,Description,Color"
    let COGSVCS_KEY = "333731fe8cdb44908a05ac8520fc6de3"
    let COGSVCS_REGION = "northcentralus"
    @IBOutlet var textlabel:UITextView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    @IBAction func buttonClicked(sender:UIButton)
    {
        if let urlImage = Bundle.main.url(forResource:"IMG_6306", withExtension:"JPG") {
            do {
                let dataImage = try Data.init(contentsOf:urlImage)
                
                if let urlService = URL.init(string:COGSVCS_CLIENTURL) {
                    
                    let urlRequest = NSMutableURLRequest.init(url:urlService)
                    urlRequest.httpMethod = "POST"
                    urlRequest.allHTTPHeaderFields = ["cache-control":"no-cache",
                                                      "target_language":"en",
                                                      "content-type":"application/octet-stream",
                                                      "Ocp-Apim-Subscription-Key": COGSVCS_KEY]
                    urlRequest.httpBody = dataImage
                    
                    let session = URLSession.shared
                    let dataTask = session.dataTask(with:urlRequest as URLRequest, completionHandler: { (data, response, error) -> Void in
                        if (error == nil) {
                            let httpResponse = response as? HTTPURLResponse
                            if httpResponse?.statusCode == 200 {

                                if let safeData = data {
                                    do {
                                        let x = try JSONSerialization.jsonObject(with:safeData, options:.mutableLeaves)
                                        print("Yay! Got a result back: \(x)")
                                        
                                        if let xAsString = x as? String {
                                            DispatchQueue.main.sync(execute: {
                                                self.textlabel!.text = xAsString
                                            })
                                        }
                                    }catch let error {
                                        print("Boo! Failed for some reason. Error = \(error)")
                                    }
                                }
                            }else{
                                print("API call returned error code \(String(describing: httpResponse?.statusCode)) :-(")
                            }
                        }

                        print("Y")
                    })
                    
                    dataTask.resume()
                    print("X")
                }
            }catch{
                print("Unable to load image")
            }
        }
    }
}
