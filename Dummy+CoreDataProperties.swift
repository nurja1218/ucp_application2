//
//  Dummy+CoreDataProperties.swift
//  
//
//  Created by Junsung Park on 2020/12/14.
//
//

import Foundation
import CoreData


extension Dummy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dummy> {
        return NSFetchRequest<Dummy>(entityName: "Dummy")
    }

    @NSManaged public var mode: Bool

}
