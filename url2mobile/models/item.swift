//
//  item.swift
//  url2mobile
//
//  Created by Hassan Ali on 10/08/2024.
//
import Foundation
import SwiftData

struct item : Decodable, Identifiable {
     let id: Int
     let url: String
     let type: String
     let createdAt: String
}
