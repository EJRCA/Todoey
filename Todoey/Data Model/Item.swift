//
//  Item.swift
//  Todoey
//
//  Created by Emanuel Andrade on 16/01/2019.
//  Copyright © 2019 Emanuel Andrade. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    
    //Set the Parent relationship with the class Category (Inverse relatioship of items). Each items has a parent category
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
