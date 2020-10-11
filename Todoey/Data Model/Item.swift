//
//  Item.swift
//  Todoey
//
//  Created by Radhi Mighri on 19/07/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import Foundation
import  RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated : Date?

    
    // reverse category : each item has a parent category
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items") // in order to get the type of the Category Class we must put .self
}
