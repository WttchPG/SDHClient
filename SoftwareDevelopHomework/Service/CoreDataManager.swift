//
//  CoreDataManager.swift
//  SoftwareDevelopHomework
//
//  Created by Wttch on 2023/10/30.
//

import Foundation
import CoreData


/// CoreData 管理类
class CoreDataManager {
    static let instance = CoreDataManager()
    
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    private init() {
        container = NSPersistentContainer(name: "SDH")
        container.loadPersistentStores { desc, error in
            if let error = error {
                logger.error("加载 CoreData 失败: \(error.localizedDescription)")
            }
        }
        
        context = container.viewContext
    }
    
    static func save() {
        do {
            try instance.context.save()
            logger.info("保存 CoreData 成功!")
        } catch let error {
            logger.error("保存 CoreData 失败: \(error.localizedDescription)")
        }
    }
    
    static func fetch<ResultType>(_ fetch: NSFetchRequest<ResultType>) -> [ResultType] where ResultType: NSFetchRequestResult {
        do {
            let result = try instance.context.fetch(fetch)
            return result
        } catch let error {
            logger.error("读取数据失败: \(error.localizedDescription)")
            return []
        }
    }
}
