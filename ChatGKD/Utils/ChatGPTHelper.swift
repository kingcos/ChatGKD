//
//  ChatGPTHelper.swift
//  ChatGKD
//
//  Created by kingcos on 2023/2/13.
//

import Foundation
import ChatGPTSwift

struct ChatGPTHelper {
    static let api = ChatGPTAPI(apiKey: "YOUR_API_KEY")
    
    static let MessagePlaceholder = "💭 思考中..."
    static let ChatErrorPrefix    = "[出错咯]"
    static let ChatStopTips       = "[已终止]"
}
