//
//  About.swift
//  LibraryCollection
//
//  Created by Elizabeth Rose on 5/2/23.
//

import SwiftUI

struct About: View {

    @State private var customColor = Color.accentColor

    var body: some View {
        NavigationStack {
            VStack {
                Text("LibraryCollection")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(customColor)
                    .padding(20)
                    .accessibilityLabel("LibraryCollection")
                Text("Developed By: Elizabeth G. Rose")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(customColor)
                    .padding(10)
                    .accessibilityLabel("Developed by Elizabeth G. Rose")
                Text("copyright 2023-2024")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(customColor)
                    .accessibilityLabel("copyright 2023-2024")
                Text("Explore documentation at the website:")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(customColor)
                    .padding(10)
                    .accessibilityLabel("See website:")
                Text("www.librarycollection.riverthree.com")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(customColor)
                    .accessibilityLabel("www.librarycollection.riverthree.com")
            }
        }
        Spacer()
    }
}

//struct About_Previews: PreviewProvider {
//    static var previews: some View {
//        About()
//    }
//
