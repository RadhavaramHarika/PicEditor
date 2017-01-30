//
//  Constants.swift
//  PicEditor
//
//  Created by radhavaram harika on 1/30/17.
//  Copyright © 2017 Practise. All rights reserved.
//

import Foundation

extension Flickr{
    
    struct Constants{
        
        struct Flickr{
            
            static let APIScheme = "https"
            static let APIHost = "api.flickr.com"
            static let APIPath = "/services/rest"
        }
        
        struct FlickrParameterKeys {
            
            static let Method = "method"
            static let APIKey = "api_key"
            static let Extras = "extras"
            static let Format = "format"
            static let NoJSONCallback = "nojsoncallback"
            static let SafeSearch = "safe_search"
            static let Text = "text"
            static let Page = "page"
        }
        
        struct FlickrParameterValues {
            
            static let SearchMethod = "flickr.photos.search"
            static let APIKey = "1dd99c5850c94276f9153472658831f5"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1" /* 1 means "yes" */
            static let MediumURL = "url_m"
            static let UseSafeSearch = "1"
        }
        
        struct FlickrResponseKeys {
            
            static let Status = "stat"
            static let Photos = "photos"
            static let Photo = "photo"
            static let Title = "title"
            static let MediumURL = "url_m"
            static let Pages = "pages"
            static let perPage = "perpage"
            static let Total = "total"
        }
        
        struct FlickrResponseValues {
            static let OKStatus = "ok"
        }
        
    }
}
