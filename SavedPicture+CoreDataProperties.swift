//
//  SavedPicture+CoreDataProperties.swift
//  PicEditor
//
//  Created by radhavaram harika on 1/30/17.
//  Copyright © 2017 Practise. All rights reserved.
//

import Foundation
import CoreData


extension SavedPicture {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedPicture> {
        return NSFetchRequest<SavedPicture>(entityName: "SavedPicture");
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var creationDate: NSDate?

}
