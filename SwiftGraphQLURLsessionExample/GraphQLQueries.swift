//
//  GraphQLQueries.swift
//  SwiftGraphQLURLsessionExample
//
//  Created by Kaori Persson on 2022-10-26.
//

// Based on the following instruction
// https://swiftstudent.com/2020-10-09-graphql-networking-using-urlsession/

import Foundation

struct Post: Decodable {
		let id: String
		let title: String
		let body: String
}

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

struct IDInput: Encodable {
		let id: String
}

struct GraphQLOperation<Input: Encodable, Output: Decodable>: Encodable {
	var input: Input
	var operationString: String
	
	private let url = URL(string: "https://graphqlzero.almansi.me/api")!
	
	enum CodingKeys: String, CodingKey {
			case variables
			case query
	}

	func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(input, forKey: .variables)
			try container.encode(operationString, forKey: .query)
	}

	func getURLRequest() throws -> URLRequest {
			var request = URLRequest(url: url)
			
			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = try JSONEncoder().encode(self)
	
			return request
	}
}

extension GraphQLOperation where Input == IDInput, Output == Post {
		static func fetchPost(withID id: String) -> Self {
				GraphQLOperation(
						input: IDInput(id: id),
						operationString: """
								query Post($id: ID!) {
									post(id:$id) {
										id
										title
										body
									}
								}
						"""
				)
		}

	static func performOperation<Input, Output>(_ operation: GraphQLOperation<Input, Output>,
																			 completion: @escaping (Result<Output, Error>) -> Void) {
			let request: URLRequest
			
			do {
					request = try operation.getURLRequest()
			} catch {
					completion(.failure(error))
					return
			}

			URLSession.shared.dataTask(with: request) { (data, _, error) in
					if let error = error {
							completion(.failure(error))
							return
					}
					
					guard let data = data else {
							completion(.failure(NSError(domain: "No data", code: 0)))
							return
					}
					
					do {
							let result = try JSONDecoder().decode(GraphQLResult<Output>.self, from: data)
							if let object = result.object {
									completion(.success(object))
							} else {
									print(result.errorMessages.joined(separator: "\n"))
									completion(.failure(NSError(domain: "Server error", code: 1)))
							}
					} catch {
							completion(.failure(error))
					}
					
			}.resume()
	}
	
	static func mainViewDidLoad1() {
		let fetchPostQuery = GraphQLOperation<IDInput, Post>.fetchPost(withID: "1")

		performOperation(fetchPostQuery) { result in
				switch result {
				case .success(let post):
						print(post)
				case .failure(let error):
						print(error)
				}
		}
	}
}
