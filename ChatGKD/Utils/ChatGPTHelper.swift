//
//  ChatGPTHelper.swift
//  ChatGKD
//
//  Created by kingcos on 2023/2/13.
//

import Foundation
import ChatGPTSwift

struct ChatGPTHelper {
    private static var _api: ChatGPTAPI?
    
    static var api: ChatGPTAPI {
        if _api == nil {
            renew()
        }
        
        return _api!
    }
    
    static func renew() {
        _api = ChatGPTAPI(apiKey: "YOUR_API_KEY")
    }
    
    static let MessagePlaceholder = "💭 思考中..."
    static let ChatErrorPrefix    = "[出错咯]"
    static let ChatStopTips       = "[已终止]"
}
