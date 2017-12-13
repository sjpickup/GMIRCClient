// Copyright © 2015 Giuseppe Morana aka Eugenio
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/// An IRC message
open class GMIRCMessage: NSObject {
    
    fileprivate(set) var prefix: GMIRCMessagePrefix?
    fileprivate(set) var command: String?
//    private(set) var parameters: String?
    fileprivate(set) var params: GMIRCMessageParams?
    
    /// format: prefix + cmd + params + crlf
    /// e.g. :card.freenode.net 001 eugenio_ios :Welcome to the freenode Internet Relay Chat Network eugenio_ios
    /// e.g. :eugenio79!~giuseppem@93-34-6-226.ip47.fastwebnet.it PRIVMSG eugenio_ios :Hi, I am Eugenio too
    init?(message: String) {
        
        super.init()

        var idx = message.startIndex
        // prefix
        if message.hasPrefix(":") {
           
            guard let prefixIdx = message.index(of: " ")
            else {
                return nil

            }
            
            self.prefix = GMIRCMessagePrefix(prefix: String(message[..<prefixIdx]) )
            
            idx = message.index(after: prefixIdx)
        }
        
        // command
        guard let commandIdx = message[idx...].index(of: " ")
            else {
                print("couldn't find command")
                return nil
        }
        
        self.command = String(message[ idx ..< commandIdx ])
        let afterCommandIdx = message.index(after: commandIdx)
        let remaining = String( message[ afterCommandIdx... ] )
        self.params = GMIRCMessageParams(fromString: remaining)
    }
}
