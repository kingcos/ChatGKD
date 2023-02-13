//
//  ChatProvider.swift
//  ChatGKD
//
//  Created by kingcos on 2023/2/13.
//

import Foundation
import CoreData

struct ChatProvider {
    static let shared = ChatProvider()
    
    let persistenceController = PersistenceController.shared
    var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    func _search() -> [ChatEntity] {
        var items = [ChatEntity]()
        let request = ChatEntity.fetchRequest()
        
        do {
            items = try viewContext.fetch(request)
        } catch {
            debugPrint("error retrieving cards: \(error)")
        }
        
        return items
    }
    
    func search() -> [ChatModel] {
        return _search().map { $0.toModel }
    }
    
    
    func saveOrUpdate(_ item: ChatModel) {
        let request = ChatEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", item.id.uuidString)
        
        if let old = try? viewContext.fetch(request).first {
            // 1. 更新
            old.id = item.id
            old.isAI = item.isGPT
            old.message = item.message
        } else {
            // 2. 新增
            let new = ChatEntity(context: viewContext)
            new.id = item.id
            new.isAI = item.isGPT
            new.message = item.message
        }
        
        if viewContext.hasChanges {
          do {
            try viewContext.save()
          } catch {
            let nserror = error as NSError
            debugPrint("Unresolved error \(nserror), \(nserror.userInfo)")
          }
        }
    }
    
    func clear() {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: ChatEntity.fetchRequest())
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch {
            debugPrint("error retrieving cards: \(error)")
        }
    }
    
    func remove(_ indexSet: IndexSet) {
        let items = _search()
        for index in indexSet {
            let entity = items[index]
            
            viewContext.delete(entity)
            if viewContext.hasChanges {
              do {
                try viewContext.save()
              } catch {
                let nserror = error as NSError
                debugPrint("Unresolved error \(nserror), \(nserror.userInfo)")
              }
            }
        }
    }
}
