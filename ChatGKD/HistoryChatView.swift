//
//  HistoryChatView.swift
//  ChatGKD
//
//  Created by kingcos on 2023/2/14.
//

import SwiftUI

struct HistoryChatView: View {
    @State var chats: [ChatModel] = []
    
    var body: some View {
        NavigationStack {
            List {
                if chats.isEmpty {
                    Text("暂无历史对话")
                } else {
                    ForEach(chats) { chat in
                        Text("\(chat.isGPT ? "🤖️" : "🧑")：\(chat.message)")
                            .bold(!chat.isGPT)
                            .contextMenu {
                                Button {
                                    UIPasteboard.general.string = chat.message
                                } label: {
                                    Label("复制", systemImage: "doc.on.doc.fill")
                                }
                            }
                    }
                    .onDelete { indexSet in
                        ChatProvider.shared.remove(indexSet)
                    }
                }
            }
            .navigationTitle("历史对话")
            .onAppear {
                chats = ChatProvider.shared.search()
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        ChatProvider.shared.clear()
                        chats = ChatProvider.shared.search()
                    } label: {
                        Image(systemName: "trash.fill")
                            .foregroundColor(Color.red)
                    }

                }
            }
        }
    }
}

struct HistoryChatView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryChatView()
    }
}
