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

import XCTest
@testable import GMIRCClient

class GMIRCClientTests: XCTestCase, GMIRCClientDelegate {

    var socket: GMSocketStub!
    var ircClient: GMIRCClient!
    var expectation: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        
        socket = GMSocketStub(host: "localhost", port: 6667)
        ircClient = GMIRCClient(socket: socket)
        ircClient.delegate = self
    }
    
    override func tearDown() {
        ircClient.delegate = nil
        ircClient = nil
        socket = nil
        
        super.tearDown()
    }

    func test_register_welcome() {
        
        socket.responseToMessage("USER eugenio 0 * : eugenio", response: ":card.freenode.net 001 eugenio :Welcome to the freenode Internet Relay Chat Network eugenio")
        
        socket.responseToMessage("JOIN #test", response: ":eugenio!~eugenio_i@93-34-6-226.ip47.fastwebnet.it JOIN :#test")

        expectation = self.expectation(description: "Welcome expectation")
        
        ircClient.register( nickName: "eugenio", user: "eugenio", realName: "eugenio")
        
        waitForExpectations(timeout: 0.05) { error in
            XCTAssertNil(error)
            
            self.expectation = self.expectation(description: "Join expectation")
            
            self.ircClient.join(channel: "#test")
            
            self.waitForExpectations(timeout: 0.05) { error in
                XCTAssertNil(error)
            }
        }
    }
    
    func test_register_welcome_without_colon() {
        
        socket.responseToMessage("USER eugenio 0 * : eugenio", response: ":card.freenode.net 001 eugenio :Welcome to the freenode Internet Relay Chat Network eugenio")
        
        socket.responseToMessage("JOIN #test", response: ":eugenio!~eugenio_i@93-34-6-226.ip47.fastwebnet.it JOIN #test")
        
        expectation = self.expectation(description: "Welcome expectation")
        
        ircClient.register( nickName: "eugenio", user: "eugenio", realName: "eugenio")
        
        waitForExpectations(timeout: 0.05) { error in
            XCTAssertNil(error)
            
            self.expectation = self.expectation(description: "Join expectation")
            
            self.ircClient.join(channel: "#test")
            
            self.waitForExpectations(timeout: 0.05) { error in
                XCTAssertNil(error)
            }
        }
    }
    
    func test_privateMessage() {

        socket.responseToMessage("PRIVMSG eugenio79 :Hi, I\'m GMIRCClient. Nice to meet you!", response: ":eugenio79!~giuseppem@93-34-6-226.ip47.fastwebnet.it PRIVMSG GMIRCClient :Hi, I am a client too")
        
        expectation = self.expectation(description: "Private message expectation")
        
        ircClient.sendPrivateMessage("Hi, I'm GMIRCClient. Nice to meet you!", toNickName: "eugenio79")
        
        waitForExpectations(timeout: 0.05) { error in
            XCTAssertNil(error)
        }
    }
    
    
    // MARK: - GMIRCClientDelegate
    
    func didWelcome() {
        expectation.fulfill()
    }
    
    func didJoin(_ channel: String) {
        XCTAssertEqual(channel, "#test")
        expectation.fulfill()
    }
    
    func didLeave(_ channel: String) {
        // TODO
    }
    
    func didReceivePrivateMessage(_ text: String, from: String) {
        print("\(from): \(text)")
        
        XCTAssertEqual(text, "Hi, I am a client too")
        XCTAssertEqual(from, "eugenio79")
        
        expectation.fulfill()
    }

    func didReceiveMessage(_ message: GMIRCMessage) {
        // TODO
    }
    
}
