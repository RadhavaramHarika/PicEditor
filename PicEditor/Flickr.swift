//
//  Flickr.swift
//  PicEditor
//
//  Created by radhavaram harika on 1/30/17.
//  Copyright © 2017 Practise. All rights reserved.
//

import UIKit
import Foundation

class Flickr: NSObject {

    let session = URLSession.shared
    
    func taskForGetRandomImage(_ methodParamters: [String:AnyObject],getRandomImageCompletionHandler: @escaping(_ results: AnyObject?,_ error: NSError?) -> Void) -> URLSessionDataTask{
        
        let request = URLRequest(url: flickrURLFromParameters(methodParamters))
        
        let task = session.dataTask(with: request){(data,response,error) in
            
            func displayError(_ error:String){
                print(error)
            }
            
            guard (error == nil) else{
                displayError("There was an error with your request")
                getRandomImageCompletionHandler(nil,NSError(domain: "getPhotosPage", code: 1,userInfo:[NSLocalizedDescriptionKey: error!]))
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                displayError("The statusCode is not in the order of 2xx")
                getRandomImageCompletionHandler(nil,NSError(domain: "getPhotosPage", code: 1,userInfo:[NSLocalizedDescriptionKey: "The statusCode is not in the order of 2xx"]))
                return
            }
            
            guard let data = data else{
                displayError("No data were returned by request")
                getRandomImageCompletionHandler(nil,NSError(domain: "getPhotosPage", code: 1,userInfo:[NSLocalizedDescriptionKey: "No data were returned by request"]))
                return
            }
            
            self.convertDataIntoJSONFormat(data, convertDataCompletionHandler: getRandomImageCompletionHandler)
        }
        
        task.resume()
        return task
    }
    
    private func convertDataIntoJSONFormat(_ data: Data,convertDataCompletionHandler: @escaping(_ results: AnyObject?,_ error: NSError?) -> Void){
        
        var parsedData:AnyObject!
        do{
            parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        }
        catch{
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the \(data) into json format"]
            convertDataCompletionHandler(nil,NSError(domain: "convertDataIntoJSONFormat",code: 1,userInfo:userInfo))
        }
        convertDataCompletionHandler(parsedData,nil)
    }
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        print(components.url!)
        return components.url!
    }
    
    class func shareInstance() -> Flickr{
        
        struct SingleTon{
            static let sharedInstance = Flickr()
        }
        return SingleTon.sharedInstance
    }
}
