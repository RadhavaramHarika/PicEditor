//
//  FlickrConvenience.swift
//  PicEditor
//
//  Created by radhavaram harika on 1/30/17.
//  Copyright © 2017 Practise. All rights reserved.
//

import Foundation
import UIKit

extension Flickr{

public func getPhotosWithPages(text: String, getPhotosWithPagescompletionHandler: @escaping(_ success: Bool,_ error: NSError?) -> Void){
    
    var methodParams = [Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
                                           Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
                                           Constants.FlickrParameterKeys.Text:text,
                                           Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
                                           Constants.FlickrResponseKeys.perPage: 20,
                                           Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
                                           Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
                                           Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback] as [String : Any]
    let task = taskForGetRandomImage(methodParams as [String : AnyObject]){(results,error) in
        
        if error != nil {
            getPhotosWithPagescompletionHandler(false,error)
            return
        }
        
        if let photoResults = results{
            
            guard let stat = photoResults[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else{
                print("Flickr Api returned an error, see the message in \(results)")
                return
            }
            
            guard let photosDictionary = photoResults[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else{
                print("Could not find the key \(Constants.FlickrResponseKeys.Photos)")
                return
            }
            
            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else{
                print("Could not find the key \(Constants.FlickrResponseKeys.Pages)")
                return
            }
            print(totalPages)
            let pageLimit = min(totalPages, 10)
            var randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            print(randomPage)
            if randomPage == 0{
                randomPage = 1
            }
            methodParams[Constants.FlickrParameterKeys.Page] = randomPage as AnyObject?
            self.getPhotosWithPageNumber(methodParams as [String : AnyObject],getPhotosWithPageNumberCompletionHandler:getPhotosWithPagescompletionHandler)
            
            
        }
        else{
            getPhotosWithPagescompletionHandler(false,NSError(domain: "getPhotosWithPages",code: 1,userInfo:[NSLocalizedDescriptionKey:"Data found as nil"]))
        }
        
    }
}

func getPhotosWithPageNumber(_ methodParameters: [String:AnyObject],getPhotosWithPageNumberCompletionHandler:@escaping(_ success:Bool,_ error: NSError?) -> Void){
    
    let parameters = methodParameters
    
    let task = taskForGetRandomImage(parameters){(results,error) in
        
        if error != nil{
            getPhotosWithPageNumberCompletionHandler(false,error)
        }
        else{
            
            if let photoResults = results{
                guard let stat = photoResults[Constants.FlickrResponseKeys.Status] as? String,stat == Constants.FlickrResponseValues.OKStatus else{
                    print("Flickr Api returned an error, see the message in \(results)")
                    getPhotosWithPageNumberCompletionHandler(false,NSError(domain: "getPhotosWithPageNumber",code: 1,userInfo:[NSLocalizedDescriptionKey:"Flickr Api returned an error, see the message in \(results)"]))
                    
                    return
                }
                
                guard let photosDictionary = photoResults[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else{
                    print("Could not find th key \(Constants.FlickrResponseKeys.Photos)")
                    getPhotosWithPageNumberCompletionHandler(false,NSError(domain: "getPhotosWithPageNumber",code: 1,userInfo:[NSLocalizedDescriptionKey:"Could not find th key \(Constants.FlickrResponseKeys.Photos)"]))
                    return
                }
                
                guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else{
                    print("Could not find the key \(Constants.FlickrResponseKeys.Photo)")
                    getPhotosWithPageNumberCompletionHandler(false,NSError(domain: "getPhotosWithPageNumber",code: 1,userInfo:[NSLocalizedDescriptionKey:"Could not find the key \(Constants.FlickrResponseKeys.Photo)"]))
                    return
                }
                
                if photosArray.count == 0{
                    print("No photo is found,Search Again")
                    getPhotosWithPageNumberCompletionHandler(false,NSError(domain: "getPhotosWithPageNumber",code: 1,userInfo:[NSLocalizedDescriptionKey:"No photo is found,Search Again!"]))
                    
                    return
                }
                else{
                    print(photosArray.count)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate

                    let photoArray = photosArray[0..<20]
                    for eachPhoto in photoArray{
                        let photoTitle = eachPhoto[Constants.FlickrResponseKeys.Title] as? String
                        
                        guard let mediumURL = eachPhoto[Constants.FlickrResponseKeys.MediumURL] as? String else{
                            print("Could not find the key \(Constants.FlickrResponseKeys.MediumURL)")
                            getPhotosWithPageNumberCompletionHandler(false,NSError(domain: "getPhotosWithPageNumber",code: 1,userInfo:[NSLocalizedDescriptionKey:"Could not find the key \(Constants.FlickrResponseKeys.MediumURL)"]))
                            return
                        }
                        appDelegate.imageURLs.append(mediumURL)
                    }
                    getPhotosWithPageNumberCompletionHandler(true,nil)
                }
            }
            else{
                
                getPhotosWithPageNumberCompletionHandler(false,NSError(domain: "getPhotosWithPageNumber",code: 1,userInfo:[NSLocalizedDescriptionKey:"Data found as nil!"]))
            }
        }
    }
    
}

func downloadImageFromImageURL(imagePath: String, completionHandlerForImageDownload: @escaping(_ success:Bool,_ imageData: Data?,_ error: NSError?) -> Void){
    
    let imageURL = URL(string: imagePath)
    let request = URLRequest(url: imageURL!)
    
    let task = session.dataTask(with: request as URLRequest) {(data,response,error) in
        
        if error != nil{
            completionHandlerForImageDownload(false,nil,NSError(domain:"ImageDownLoad",code: 1,userInfo:[NSLocalizedDescriptionKey:"Could not dowloadImage"]))
        }
        else{
            completionHandlerForImageDownload(true,data,nil)
        }
    }
    task.resume()
}


}
