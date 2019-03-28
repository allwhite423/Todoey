//
//  Item.swift
//  Todoey
//
//  Created by Daheen Lee on 29/03/2019.
//  Copyright © 2019 allwhite. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    //reversing relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
