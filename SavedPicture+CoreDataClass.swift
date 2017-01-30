//
//  SavedPicture+CoreDataClass.swift
//  PicEditor
//
//  Created by radhavaram harika on 1/30/17.
//  Copyright © 2017 Practise. All rights reserved.
//

import Foundation
import CoreData


public class SavedPicture: NSManagedObject {

    convenience init(imageData: NSData,context: NSManagedObjectContext){
        if let en = NSEntityDescription.entity(forEntityName: "SavedPicture", in: context){
            self.init(entity:en, insertInto: context)
            self.creationDate = Date() as NSDate?
            self.imageData = imageData
        }
        else{
            fatalError("Unable to find Entity name")
        }
    }
    
    var humanReadableDate: String {
        get {
            let formatter = DateFormatter()
            formatter.timeStyle = .none
            formatter.dateStyle = .short
            formatter.doesRelativeDateFormatting = true
            formatter.locale = Locale.current
            return formatter.string(from: creationDate! as Date)
        }
    }
}
