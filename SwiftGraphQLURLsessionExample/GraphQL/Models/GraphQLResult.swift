//
//  GraphQLResult.swift
//  SwiftGraphQLURLsessionExample
//
//  Created by Kaori Persson on 2022-10-26.
//

import Foundation

struct GraphQLResult<T: Decodable>: Decodable {
		let object: T?
		let errorMessages: [String]
		
		enum CodingKeys: String, CodingKey {
				case data
				case errors
		}
		
		struct Error: Decodable {
				let message: String
		}
		
		init(from decoder: Decoder) throws {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				
				let dataDict = try container.decodeIfPresent([String: T].self, forKey: .data)
				self.object = dataDict?.values.first
				
				var errorMessages: [String] = []
				
				let errors = try container.decodeIfPresent([Error].self, forKey: .errors)
				if let errors = errors {
						errorMessages.append(contentsOf: errors.map { $0.message })
				}
				
				self.errorMessages = errorMessages
		}
}
