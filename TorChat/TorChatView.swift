//
//  TorChatView.swift
//  TorChat
//
//  Created by Florian Hubl on 29.10.23.
//

import SwiftUI
import Telegraph
import SwiftTor

struct TorChatView: View {
    
    @ObservedObject var tor: SwiftTor
    let server: Server
    
    @ObservedObject var model: Model
    
    @State private var textfield = ""
    
    @FocusState var focus: Bool
    
    var sta: String {
        switch model.sta {
        case.connected:
            "Connected"
        case .connecting:
            "Connecting…"
        case .connectingAddresses:
            "connected"
        case .noAddresses:
            "No onion addresses"
        case .error:
            "Error"
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("TorChat")
                        .bold()
                        .font(.largeTitle)
                        .foregroundStyle(model.sta == .connected ? .purple : .black)
                        .padding()
                }
                Text(sta)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Spacer()
                ScrollViewReader { proxy in
                    ScrollView {
                        Spacer(minLength: 11)
                        ForEach(model.chat, id: \.self) { item in
                            MessageView(message: item)
                                .id(item.id)
                        }
                        .onChange(of: model.chat) { newValue in
                            guard model.chat.isEmpty == false else {return}
                            withAnimation {
                                proxy.scrollTo(model.chat.last!.id)
                            }
                        }
                    }
                }
                TextField("Start chatting…", text: $textfield)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focus)
                    .padding()
                    .onSubmit {
                        send()
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button("Send") {
                                send()
                            }
                        }
                    }
            }
        }
        .animation(.spring(), value: model.chat)
        .animation(.easeInOut, value: model.sta)
        .onChange(of: tor.state) { connection in
            guard model.sta == .connecting else {return}
            if connection == .connected {
                model.sta = .connectingAddresses
            }
        }
        .onChange(of: model.connectedAddresses) { newValue in
            guard model.sta == .connectingAddresses else {return}
            if newValue.count > 0 {
                model.sta = .connected
            }
        }
    }
    
    func send() {
        guard textfield.isEmpty == false else {return}
        let message = textfield
        textfield = ""
        focus = false
        model.chat.append(Message(message: message, ownMessage: true))
        Task {
            for address in model.connectedAddresses {
                var adr = address
                if adr.last! == "/" {
                    print("Last is slash")
                    adr.removeLast()
                    if adr.last! != "/" {
                        print("Last is not Slash")
                        adr = address
                    }
                }else {
                    adr = "\(address)/"
                }
                guard let url = URL(string: "\(adr)\(message)") else {return}
                print("Send \(url.absoluteString)")
                let a = try await tor.request(request: URLRequest(url: url)).0
                let b = String(data: a, encoding: .utf8)!
                print("Recieved Result: \(b)")
                guard b == "done" else {
                    model.sta = .error
                    return
                }
            }
        }
    }
}
