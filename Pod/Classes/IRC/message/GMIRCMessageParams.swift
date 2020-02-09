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

/// Encapsulates an IRC message params
open class GMIRCMessageParams: NSObject {
    
    /// Here I put everything I'm not still able to parse
    fileprivate(set) var unparsed: String?
    
    /// e.g. the target of a PRIVMSG
    fileprivate(set) var msgTarget: String?
    
    /// e.g. the the text of a PRIVMSG
    fileprivate(set) var textToBeSent: String?

    /// @param stringToParse e.g. "eugenio_ios :Hi, I am Eugenio too"
    init( fromString: String) {
        
        super.init()
        
        var idx = fromString.startIndex
        
        if let msgTargetIdx = fromString.firstIndex(of: " ")
        {
            self.msgTarget = String( fromString[..<msgTargetIdx] )
            idx = fromString.index(after: msgTargetIdx)
        }
        
        
        let remaining = fromString[idx...]
        if( remaining.hasPrefix(":"))
        {
            idx = remaining.index(after: idx)
        }
        
        self.textToBeSent = String( fromString[idx...] )
    }
}
