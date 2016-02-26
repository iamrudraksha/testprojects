//
//  Idea.swift
//  CardinalHealth
//
//  Created by Volkov Alexander on 23.06.15.
//  Copyright (c) 2015 Topcoder. All rights reserved.
//

import Foundation
import CoreData

/**
* Data object used to create a new idea
*
* @author Alexander Volkov
* @version 1.0
*/
class IdeaData {
    
    var id: String = ""
    var created: NSDate = NSDate()
    var title: String = ""
    var text: String = ""
    
    var submitter: String?
    var submitterTitle: String = ""
    var submitterEmail: String = ""
    
    /// Author's profile icon  URL. Added for future.
    var submitterIconUrl: String?
    
    /*
    Flag: true - this is author's idea (not of another person), false - else.
    This flag is not a ownership flag. The idea can be submitted by current user (shown in 'My idea'),
    but it can be not his idea. This flag reflects the second switcher in the 'Submit idea' form.
    */
    var submitterIdea: Bool = true

}

/**
* Model object for ideas
*
* @author Alexander Volkov
* @version 1.0
*/
@objc(Idea)
class Idea: NSManagedObject {
    
    @NSManaged var id: String
    @NSManaged var created: NSDate
    @NSManaged var title: String
    @NSManaged var text: String

    @NSManaged var submitter: String?
    @NSManaged var submitterTitle: String
    @NSManaged var submitterEmail: String

    /// Author's profile icon  URL. Added for future.
    @NSManaged var submitterIconUrl: String?
    
    /*
    Flag: true - this is author's idea (not of another person), false - else.
    This flag is not a ownership flag. The idea can be submitted by current user (shown in 'My idea'),
    but it can be not his idea. This flag reflects the second switcher in the 'Submit idea' form.
    */
    @NSManaged var submitterIdea: Bool
    
    /// flag: true - the idea is anonymous, false - there is a known submitter
    var isAnonymous: Bool {
        return submitter == nil
    }
    
    private var json: JSON?
    
    ///  extra parameter that is added in the app (not presented in server response)
    @NSManaged var isNew: Bool
    
    /**
    Get string representation of the date
    
    :returns: date string, e.g. "2 days ago" or "May 22
    */
    func getDateString() -> String {
        let timeInterval = NSDate().timeIntervalSinceDate(self.created)
        let daysLeft = abs(timeInterval) / (24 * 60 * 60)
        println("title=\(title) getDateString=\(timeInterval) daysLeft=\(daysLeft)")
        if daysLeft <= 30 {
            return self.created.timeToNow()
        }
        else {
            return IdeaFormatters.dateFormatter.stringFromDate(self.created)
        }
    }
    
    /**
    Parse Idea object from given JSON data.
    The methods changes Core Data objects. Hence you need to save context after that.
    
    :param: json JSON data
    
    :returns: Idea instance
    */
    class func fromJson(json: JSON) -> Idea {
        var ideaId: String = ""
        if let str = json["ideaId"].string {
            ideaId = str
        }
        else if let id = json["ideaId"].int {
            ideaId = "\(id)"
        }
        
        // Get new or updated idea
        let idea = Idea.getIdeaById(ideaId)
        idea.id = ideaId
        
        struct Static {
            static var dateParser: NSDateFormatter = {
                let f = NSDateFormatter()
                f.dateFormat = "yyyy-MM-dd"
                return f
            }()
        }
        if let date = Static.dateParser.dateFromString(json["createdTimestamp"].stringValue) {
            idea.created = date
        }
        else if let date = NSDate.parseFullDate(json["createdTimestamp"].stringValue) {
            idea.created = date
        }
        idea.title = json["ideaTitle"].stringValue
        idea.text = json["idea"].stringValue
        
        idea.submitter = json["submitter"].stringValue
        idea.submitterTitle = json["submitterTitle"].stringValue
        idea.submitterEmail = json["submitterEmail"].stringValue
        idea.submitterIconUrl = json["submitterIconUrl"].string
        idea.submitterIdea = json["submitterIdea"].boolValue
        
        if json["anonymous"].boolValue {
            idea.submitter =  nil     // in model object 'anonymous' flag depends on nil 'submitter' field
        }
        
        idea.json = json
        
        return idea
    }
    
    /**
    Find and return idea with given id. If there is no such idea, then create a new.
    
    :param: id the id
    
    :returns: idea object
    */
    class func getIdeaById(id: String) -> Idea {
        var ideaWithGivenId: Idea!
        for idea in Idea.findAll(AppDelegate.sharedInstance.managedObjectContext!) {
            if idea.id == id {
                return idea
            }
        }
        
        // Create new idea
        if ideaWithGivenId == nil {
            ideaWithGivenId = Idea.create(AppDelegate.sharedInstance.managedObjectContext!)
        }
        return ideaWithGivenId
    }
    
    /**
    Fetch all objects from Core Data
    
    :param: context the context for Core Data
    :return: all ideas
    */
    class func findAll(context: NSManagedObjectContext) -> [Idea] {
        
        // Get entity name
        let entityName = NSStringFromClass(self)
        
        // Create a new fetch request
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
        // Sort by id
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        // Get the object
        var objects = context.executeFetchRequest(fetchRequest, error: nil)
        if objects == nil {
            return []
        }
        
        // Convert the objects to speakers
        var list = [Idea]()
        for object in objects! {
            list.append(object as! Idea)
        }
        return list
    }
    
    /**
    Create a new instance
    
    :param: context the context for Core Data
    :return: a new instance
    */
    class func create(context: NSManagedObjectContext) -> Idea {
        let entityName = NSStringFromClass(self)
        var object: AnyObject? = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context)
        return object as! Idea
    }
    
    /**
    Delete all objects from Core Data
    
    :param: context the context for Core Data
    */
    class func deleteAll(context: NSManagedObjectContext) {
        var list = findAll(context)
        for object in list {
            context.deleteObject(object)
        }
        
        var error: NSError? = nil
        if !context.save(&error) {
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
}

/**
* Shortcut methods for reuse
*
* @author Alexander Volkov
* @version 1.0
*/
extension Idea {
    
    /**
    Check if this idea corresponds to current user
    
    :returns: true - if the idea was generated by the current use, false - else
    */
    func isMyIdea() -> Bool {
        if let info = LastUserInfo {
            return self.submitterEmail == info.email
        }
        return false
    }
    
    /**
    Filter the list of ideas and return only current user ideas
    
    :param: list the list
    
    :returns: current user ideas
    */
    class func filterMyIdeas(var list: [Idea]) -> [Idea] {
        if let info = LastUserInfo {
            list = list.filter({ $0.submitterEmail == info.email })
        }
        else {
            println("Email is not specified. Showing empty list for \"My Ideas\"")
            list = []
        }
        return list
    }
    
    /**
    Filter the list of ideas and return only new ideas
    
    :param: list the list
    
    :returns: new ideas
    */
    class func filterNewIdeas(var list: [Idea]) -> [Idea] {
        return list.filter({ $0.isNew })
    }
}