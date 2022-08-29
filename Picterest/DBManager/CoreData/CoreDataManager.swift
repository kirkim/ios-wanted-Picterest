//
//  CoreDataManager.swift
//  Picterest
//
//  Created by 김기림 on 2022/07/28.
//

import CoreData
import Foundation

class CoreDataManager {
    private enum NameSpace {
        static let persistentContainerName = "Model"
    }
    
    static var shared: CoreDataManager = CoreDataManager()
    
    lazy private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: NameSpace.persistentContainerName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private var imageInfos = [ImageCoreInfo]()
        
    private init() {
        let request: NSFetchRequest<ImageCoreInfo> = ImageCoreInfo.fetchRequest()
        
        do {
            imageInfos = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
    }
    
    func saveImageInfo(_ id: UUID, _ message: String, _ aspectRatio: Double, _ imageURL: String, _ imageFileLocation: String) -> Bool {
        let newImageInfo = ImageCoreInfo(context: context)
        newImageInfo.id = id
        newImageInfo.message = message
        newImageInfo.aspectRatio = aspectRatio
        newImageInfo.imageURL = imageURL
        newImageInfo.imageFileLocation = imageFileLocation
        
        imageInfos.append(newImageInfo)
        return saveContext()
    }
    
    func saveContext() -> Bool {
        do {
            try context.save()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func isContainImage(imageURL: String) -> Bool {
        var isContainImage = false
        for info in imageInfos {
            if info.imageURL == imageURL {
                isContainImage = true
                break
            }
        }
        return isContainImage
    }
    
    func readImageInfos() -> [ImageCoreInfo] {
        return imageInfos
    }
    
    func removeAllImageInfos() -> Bool {
        for info in imageInfos {
            context.delete(info)
        }
        imageInfos.removeAll()
        return saveContext() && imageInfos.isEmpty
    }
    
    func removeImageInfo(at id: UUID) throws -> String {
        var result: String?
        for info in imageInfos {
            if (info.id == id) {
                guard let imageFileLocation = info.imageFileLocation else { break }
                context.delete(info)
                if saveContext() {
                    result = imageFileLocation
                    break
                } else {
                    throw DBManagerError.failToRemoveImageInfo
                }
            }
        }
        guard let result = result else {
            throw DBManagerError.failToRemoveImageInfo
        }
        return result
    }
}
