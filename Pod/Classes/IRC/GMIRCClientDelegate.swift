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

@objc public protocol GMIRCClientDelegate: NSObjectProtocol {
    
    /// When this method is called, the channel is ready
    /// At this point you can join a chat room
    func didWelcome()
    
    /// Called when successfully joined a chat room
    /// @param channel Prepend an hash symbol (#) to the chat room name, e.g. "#test"
    func didJoin(_ channel: String)

    /// Called when successfully left a chat room
    /// @param channel Prepend an hash symbol (#) to the chat room name, e.g. "#test"
    func didLeave(_ channel: String)    
    
    /// Called when someone sent you a private message
    /// @param text The text sent by the user
    /// @param from The nickName of who sent you the message
    func didReceivePrivateMessage(_ text: String, from: String)

    /// Called when someone sent a message to the channel
    /// @param text The text sent by the user
    /// @param from The nickName of who sent the message
    func didReceiveMessage(_ message: GMIRCMessage)
}
