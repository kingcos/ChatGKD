//
//  ChatModel.swift
//  ChatGKD
//
//  Created by kingcos on 2023/2/13.
//

import Foundation

struct ChatModel: Identifiable {
    var id = UUID()
    
    var isGPT: Bool
    var message: String
}

extension ChatEntity {
    var toModel: ChatModel {
        ChatModel(id: id ?? UUID(), isGPT: isAI, message: message ?? "")
    }
}
