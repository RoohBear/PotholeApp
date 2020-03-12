//
//  ViewController.swift
//  CallAzureFromSwift
//
//  Created by G Bear on 2020-02-27.
//  Copyright © 2020 Rooh Bear Corporation. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    let COGSVCS_CLIENTURL = "https://northcentralus.api.cognitive.microsoft.com/vision/v2.1/analyze?visualFeatures=Categories,Description,Color"
    let COGSVCS_KEY = "333731fe8cdb44908a05ac8520fc6de3"
    let COGSVCS_REGION = "northcentralus"
    @IBOutlet var textlabel:UITextView!
    @IBOutlet var imageview:UIImageView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let urlImage = info[UIImagePickerController.InfoKey.imageURL] as? URL {
        
            do {
                let dataImage = try Data.init(contentsOf:urlImage)
                self.callAzure(dataImage:dataImage)
            }catch{
            
            }
        }
        
        picker.dismiss(animated:true, completion:nil)
    }
    
    @IBAction func buttonTakePhotoClicked(sender:UIButton)
    {
        let docPicker = UIImagePickerController.init()
        docPicker.sourceType = .camera
        docPicker.delegate = self
        self.present(docPicker, animated:true, completion: nil)
    }
    
    @IBAction func buttonPickPhotoClicked(sender:UIButton)
    {
        let docPicker = UIImagePickerController.init()
        docPicker.sourceType = .photoLibrary
        docPicker.delegate = self
        self.present(docPicker, animated:true, completion: nil)
    }
    
    @IBAction func buttonPotholeTestClicked(sender:UIButton)
    {
    }
    
    @IBAction func buttonAzureTestClicked(sender:UIButton)
    {
        if let urlImage = Bundle.main.url(forResource:"IMG-20200212-WA0005", withExtension:"jpg") {
            do {
                let dataImage = try Data.init(contentsOf:urlImage)
                self.callAzure(dataImage:dataImage)
            }catch{
                print("Unable to load image")
            }
        }
    }
    
    func callAzure(dataImage:Data)
    {
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
                                if let x = try JSONSerialization.jsonObject(with:safeData, options:.mutableLeaves) as?  NSDictionary {
                                    print("Yay! Got a result back: \(x)")

                                    if let dictDescription = x["description"] as? NSDictionary {
                                        if let arrCaptions = dictDescription["captions"] as? NSArray {
                                            if let firstElement = arrCaptions.firstObject as? NSDictionary {

                                                if let firstCaptionText = firstElement["text"] as? String {
                                                    DispatchQueue.main.sync(execute: {
                                                        self.textlabel!.text = firstCaptionText
                                                    })
                                                }
                                            }
                                            
                                        }
                                    }
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
    }
}
