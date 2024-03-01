//
//  item.swift
//  Scanner
//
//  Created by Hassan Ali on 01/03/2024.
//

import Foundation
import SwiftData

@Model
class item {
    var url: String
    var id = UUID()
    var date: Date = Date.now
    init(url: String, id: UUID = UUID()) {
        self.url = url
        self.id = id
    }
    
    
    
}
