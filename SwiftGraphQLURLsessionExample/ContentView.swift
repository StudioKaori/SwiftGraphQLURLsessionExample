//
//  ContentView.swift
//  SwiftGraphQLURLsessionExample
//
//  Created by Kaori Persson on 2022-10-26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
				.onAppear {
					GraphQLOperation.mainViewDidLoad1()

				}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
