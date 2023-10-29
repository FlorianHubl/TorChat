//
//  ContentView.swift
//  TorChat
//
//  Created by Florian Hubl on 29.10.23.
//

import SwiftUI
import Telegraph
import SwiftTor
import LocalStorage

struct Message: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    let message: String
    let ownMessage: Bool
}

class Model: ObservableObject {
    @Published var connectedAddresses = [String]()
    @LocalStorage("TorAddresses") var addresses = [String]()
    @Published var connecting = [String]()
    @Published var chat = [Message]()
    
    @Published var firstConnect = false
    
    @Published var sta = ConnectState.connecting
    
    func first(tor: SwiftTor) {
        if firstConnect {
            if connectedAddresses.count > 0 {
                self.sta = .connected
            }
        }else {
            for address in addresses {
                connectAddress(address: address, tor: tor)
            }
            firstConnect = true
        }
    }
    
    func connectAddress(address: String, tor: SwiftTor) {
        print("connectAddress: \(address)")
        guard address.contains("onion") else {return}
        var adr = address
        if adr.contains("http://") == false {
            adr = "http://\(adr)/"
            print("New Adr: \(adr)")
        }
        guard let url = URL(string: adr) else {return}
        print("URL ok")
        guard connectedAddresses.contains(adr) == false else {return}
        print("1")
        guard connecting.contains(adr) == false else {return}
        print("2")
        print(addresses)
        if addresses.contains(adr) == false {
            addresses.append(adr)
        }
        connecting.append(adr)
        print(connecting)
        Task {
            do {
                let result = try await tor.request(request: URLRequest(url: url)).0
                let s = String(data: result, encoding: .utf8)
                print(s!)
                if s == "TorChat" {
                    let a = connecting.firstIndex(of: adr)!
                    connecting.remove(at: a)
                    connectedAddresses.append(adr)
                }else {
                    let i = connecting.firstIndex(of: adr)!
                    connecting.remove(at: i)
                }
            }catch {
                let i = connecting.firstIndex(of: adr)!
                connecting.remove(at: i)
            }
        }
    }
}

enum MainView {
    case info
    case messages
    case settings
}

enum ConnectState {
    case connecting
    case error
    case connectingAddresses
    case noAddresses
    case connected
}

struct ContentView: View {
    
    @StateObject var tor = SwiftTor(hiddenServicePort: 100)
    
    @StateObject var model = Model()
    
    let server = Server()
    
    @State private var view = MainView.messages
    
    var body: some View {
        TabView(selection: $view) {
            TorQRView(tor: tor, model: model)
                .tabItem {
                    Image(systemName: "gear")
                }
                .tag(MainView.settings)
            TorChatView(tor: tor, server: server, model: model)
                .tabItem {
                    Image(systemName: "message")
                }
                .tag(MainView.messages)
            InfoView()
                .tabItem {
                    Image(systemName: "info")
                }
                .tag(MainView.info)
        }
        .tint(.purple)
        .environmentObject(tor)
        .onAppear(perform: startServer)
    }
    
    func startServer() {
        try! server.start(port: 100)
        server.route(.GET, ":message", handleMessage)
        server.route(.GET, "", handleHello)
        print("Started Server")
    }
    
    func handleHello(request: HTTPRequest) -> HTTPResponse {
        print("Request")
        return HTTPResponse(content: "TorChat")
    }
    
    func handleMessage(request: HTTPRequest) -> HTTPResponse {
        guard let message = request.params["message"] else {return HTTPResponse(content: "Error")}
        Task { @MainActor in
            model.chat.append(Message(message: message, ownMessage: false))
        }
        return HTTPResponse(content: "done")
    }
}

#Preview {
    ContentView()
}
