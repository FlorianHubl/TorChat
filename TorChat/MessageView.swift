//
//  MessageView.swift
//  TorChat
//
//  Created by Florian Hubl on 29.10.23.
//

import SwiftUI

struct MessageView: View {
    
    let message: Message
    
    var body: some View {
        HStack {
            if message.ownMessage {
                Spacer()
            }
            Text(message.message)
                .foregroundColor(message.ownMessage ? .black : .white)
                .background {
                    RoundedRectangle(cornerRadius: 11)
                        .foregroundColor(message.ownMessage ? .white : .black)
                        .shadow(radius: 1)
                        .padding(-10)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
            if message.ownMessage == false {
                Spacer()
            }
        }
    }
}

#Preview {
    MessageView(message: Message(message: "Hallo", ownMessage: true))
}
