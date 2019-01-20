//
//  Category.swift
//  Todoey
//
//  Created by Emanuel Andrade on 16/01/2019.
//  Copyright © 2019 Emanuel Andrade. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""

    //Set a relationship with the class Item. Forward relationship, each category have a list of items
    let items = List<Item>()
}
