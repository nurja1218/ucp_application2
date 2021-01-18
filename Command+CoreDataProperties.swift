//
//  Command+CoreDataProperties.swift
//  
//
//  Created by Junsung Park on 2020/11/19.
//
//

import Foundation
import CoreData


extension Command {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Command> {
        return NSFetchRequest<Command>(entityName: "Command")
    }

    @NSManaged public var command: String?
    @NSManaged public var enable: Bool
    @NSManaged public var gesture: String?
    @NSManaged public var group: String?
    @NSManaged public var name: String?
    @NSManaged public var shortcut: String?
    @NSManaged public var touch: String?
    @NSManaged public var type: String?
    @NSManaged public var userid: String?

}
