# TorChat

A iOS Chat App in which users can chat with nearby iPhones.

<img src="https://github.com/FlorianHubl/TorChat/blob/main/TorChatIcon.png" width="300">

The app creates a local Server on the Port 100 with the Telegraph Swift Package.
Next a Tor instance starts via SwiftTor. Then the app creates a Tor Hidden Service on the Port 100.
With this setup the app can send and recieve messages over Tor.
