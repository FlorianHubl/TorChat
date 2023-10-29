//
//  InfoView.swift
//  TorChat
//
//  Created by Florian Hubl on 29.10.23.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        Form {
            Text("The app creates a local Server on the Port 100 with the Telegraph Swift Package. Next a Tor instance starts via SwiftTor. Then the app creates a Tor Hidden Service on the Port 100. With this setup the app can send and recieve messages over Tor.")
        }
    }
}

#Preview {
    InfoView()
}
