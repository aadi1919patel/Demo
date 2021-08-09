//
//  DataStructures.swift
//  InterviewTask
//
//  Created by d3vil_mind on 03/08/21.
//

import Foundation

//==================LoginStruct=================

//MARK:- MessageStruct
struct MessageStruct: Codable {
    var result: Bool?
    var message: String?

    enum CodingKeys: String, CodingKey {
        case result, message
    }
}


// MARK: - LoginStruct
struct LoginStruct: Codable {
    var result: Bool?
    var message: String?
    var userID: Int?
    var fullname: String?

    enum CodingKeys: String, CodingKey {
        case result, message
        case userID = "userId"
        case fullname
    }
}


//==================CategoriesStruct=================

// MARK: - CategoriesStruct
struct CategoriesStruct: Codable {
    var categories: [Category]?
}

// MARK: - Category
struct Category: Codable {
    var id: Int?
    var title: String?
    var image: String?
}

// MARK: - Welcome
struct CateGorySos: Codable {
    let page, perPage, total, totalPages: Int
    let data: [Data]
    let support: Support

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case total
        case totalPages = "total_pages"
        case data, support
    }
}

// MARK: - Datum
struct Data: Codable {
    let id: Int
    let name: String
    let year: Int
    let color, pantoneValue: String

    enum CodingKeys: String, CodingKey {
        case id, name, year, color
        case pantoneValue = "pantone_value"
    }
}

// MARK: - Support
struct Support: Codable {
    let url: String
    let text: String
}
