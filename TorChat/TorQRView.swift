//
//  TorQRView.swift
//  TorChat
//
//  Created by Florian Hubl on 29.10.23.
//

import SwiftUI
import QRKit
import LocalStorage
import SwiftTor

enum LoadingState: Codable {
    case loading
    case error
    case done
}

struct TorQRView: View {
    
    @ObservedObject var tor: SwiftTor
    
    @ObservedObject var model: Model
    
    @State private var showCamera = false
    
    var body: some View {
        Form {
            if let onionAddress = tor.onionAddress {
                QRCode(data: onionAddress, copyable: true)
                Section {
                    ForEach(model.addresses, id: \.self) { i in
                        HStack {
                            Text(i)
                                .foregroundStyle(model.connectedAddresses.contains(i) ? .green : .black)
                                .onTapGesture {
                                    model.connectAddress(address: i, tor: tor)
                                }
                            if model.connecting.contains(i) {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                }
                Button("Add onion address") {
                    showCamera = true
                }
                Button("Clear") {
                    model.sta = .connectingAddresses
                    model.connecting.removeAll()
                    model.addresses.removeAll()
                    model.connectedAddresses.removeAll()
                }
            }else {
                HStack {
                    Text("Loading onion address…")
                    Spacer()
                    ProgressView()
                }
            }
        }
        .animation(.easeInOut, value: model.addresses)
        .animation(.easeInOut, value: tor.onionAddress)
        .sheet(isPresented: $showCamera) {
            VStack {
                QRScannerView { result in
                    showCamera = false
                    newOnionAddress(input: result)
                }
                Button("clipboard") {
                    guard let clipboard = UIPasteboard.general.string else {return}
                    showCamera = false
                    newOnionAddress(input: clipboard)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
    }
    
    func newOnionAddress(input: String) {
        print("NewOnion: \(input)")
        print("adr: \(model.addresses)")
        guard model.addresses.contains(input) == false else {return}
        guard input != tor.onionAddress ?? "" else {return}
        model.connectAddress(address: input, tor: tor)
    }
}

