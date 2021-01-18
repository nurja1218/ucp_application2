//
//  Users+CoreDataProperties.swift
//  
//
//  Created by Junsung Park on 2020/12/14.
//
//

import Foundation
import CoreData


extension Users {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Users> {
        return NSFetchRequest<Users>(entityName: "Users")
    }

    @NSManaged public var answer: String?
    @NSManaged public var country: String?
    @NSManaged public var enable: Bool
    @NSManaged public var name: String?
    @NSManaged public var password: String?
    @NSManaged public var type: String?
    @NSManaged public var userid: String?

}
