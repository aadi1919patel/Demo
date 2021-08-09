//
//  Item.swift
//  InterviewTask
//
//  Created by d3vil_mind on 03/08/21.
//

import Foundation
import RealmSwift

class Item : Object {
    
    @objc dynamic var id = 0
    @objc dynamic var itemImage = Data()
    @objc dynamic var title = ""
    @objc dynamic var category = ""
    @objc dynamic var price = ""
    @objc dynamic var inStock = 0
    
}
