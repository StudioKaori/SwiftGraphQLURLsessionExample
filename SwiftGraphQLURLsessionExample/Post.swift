//
//  Post.swift
//  SwiftGraphQLURLsessionExample
//
//  Created by Kaori Persson on 2022-10-26.
//

import Foundation

struct Post: Decodable {
		let id: String
		let title: String
		let body: String
}
