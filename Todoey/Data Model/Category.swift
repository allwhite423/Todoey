//
//  Category.swift
//  Todoey
//
//  Created by Daheen Lee on 29/03/2019.
//  Copyright © 2019 allwhite. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    
    let items = List<Item>() //forward relationship
}
