//
//  Category.swift
//  Todoey
//
//  Created by Radhi Mighri on 19/07/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import Foundation
import  RealmSwift

class Category: Object {
   @objc dynamic var name: String = ""
   @objc dynamic var colour: String = ""
    // forward relationship : each Category has a list of items
    let items = List<Item>() //create a list of items and initialise it to empty
}
