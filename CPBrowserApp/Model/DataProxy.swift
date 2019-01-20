//
//  DataProxy.swift
//  CPBrowserApp
//
//  Created by Asaf h on 1/20/19.
//  Copyright © 2019 A h. All rights reserved.
//

import Foundation
import CoreData


class DataProxy {
    var originalUrl:String?
    var redirects:[String]?
    private var isTracked:Bool = false
    private var context:NSManagedObjectContext
    
    init(dataContext:NSManagedObjectContext) {
        context = dataContext
    }
    
    func onNewBrowse(url:String) {
        if shouldBeTracked(newUrl: url) {
            originalUrl = url
            isTracked = true
            redirects = [String]()
        } else {
            isTracked = false
        }
    }
    
    func onRedirect(redirectUrl:String) {
        if isTracked {
            redirects!.append(redirectUrl)
        }
    }
    
    func onCompletion() {
        if isTracked {
            addUrlEntity(url: originalUrl!, redirects: redirects!)
        }
    }
    
    func addUrlEntity(url:String, redirects:[String]) {
        let entity = NSEntityDescription.entity(forEntityName: "Url", in: context)
        let newUrl = NSManagedObject(entity: entity!, insertInto: context)
        
        newUrl.setValue(url, forKey: "url")
        newUrl.setValue(redirects, forKey: "redirects")
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func shouldBeTracked(newUrl:String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Url")
        request.predicate = NSPredicate(format: "url = %@", newUrl)
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.count(for: request)
            return (results == 0)
        } catch {
            print("Failed")
        }
        return false
    }
    
    func getUrlHistory() -> [Url]? {
        
        let urlHistoryFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Url")
        
        do {
            let urlHistory = try context.fetch(urlHistoryFetch) as! [Url]
            return urlHistory
        } catch {
            fatalError("Failed to fetch urls: \(error)")
        }
        return nil
    }
    
}

