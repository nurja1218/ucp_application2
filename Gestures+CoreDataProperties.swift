//
//  Gestures+CoreDataProperties.swift
//  
//
//  Created by Junsung Park on 2020/11/19.
//
//

import Foundation
import CoreData


extension Gestures {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gestures> {
        return NSFetchRequest<Gestures>(entityName: "Gestures")
    }

    @NSManaged public var app_name: String?
    @NSManaged public var code: String?
    @NSManaged public var command: String?
    @NSManaged public var name: String?
    @NSManaged public var shortcut: String?
    @NSManaged public var touch: String?

}
