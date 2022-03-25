//
//  CoreDataClass.swift
//  CFT_Task
//
//  Created by Даниил Ярмоленко on 24.03.2022.
//

import Foundation
import CoreData

class CoreDataClass {
    
    var persistentContainer: NSPersistentContainer = {
          let container = NSPersistentContainer(name: "SavingLearn")
          container.loadPersistentStores(completionHandler: { (storeDescription, error) in
              if let error = error as NSError? {
                  fatalError("Unresolved error \(error), \(error.userInfo)")
              }
          })
          return container
      }()
    
    func saveContext () {
        context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
      }()
}
