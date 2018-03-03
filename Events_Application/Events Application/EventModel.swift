//
//  EventModel.swift
//  Events Application
//
//  Created by Kristian Curcic on 30/11/2017.
//  Copyright © 2017 Kristian Curcic. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class EventList
{
    // Array of event objects
    static var listOfEvents = [Event]()
    
    static var eventService:EventService?
    
    // Function to get events from API
    static func getEventsFromWebService(_ siteURL:String, _ searchTerm:String)->[Event]   
    {
        // JSON URL with values for site URL and search term (keywords) to be added
        let searchURL = "http://\(siteURL)/json/events/search?keywords=\(searchTerm)&app_key=wjwMpjZWRD7JXHPQ"
        print ("Web Service call = \(searchURL)")
    
        eventService = EventService(searchURL)
        
        // Runs operation queue to pull JSON from URL
        let operationQ = OperationQueue()

        operationQ.maxConcurrentOperationCount = 1

        operationQ.addOperation(eventService!)

        operationQ.waitUntilAllOperationsAreFinished()
        
        listOfEvents.removeAll()
        
        // JSON parsed from URL
        let returnedJSON = eventService!.jsonFromResponse
        
        // Method to access JSON objects
        if let allEventsJSON = returnedJSON?["events"] as? [String:Any]
        {
            // JSON is nested twice
            let JSONObjects = allEventsJSON["event"] as! [[String:Any]]
            
            for eachJSONObject in JSONObjects
            {
                // Appends JSON event to array of events
                print("Creating event object from JSON: \(eachJSONObject)")
                listOfEvents.append(Event(eachJSONObject))
            }
        }
        
        // Returns events
        return listOfEvents
    }

    // Displays events
    private static func showCreatedList()
    {
        for evt in listOfEvents
        {
            print(evt.displayEvent())
        }
        
    }
    
    static func getSavedEvents()->[Event]{
        
        var savedEvents:[Event] = [Event]()
        
        var retrievedEvents:[SavedEvent]
        
        // Access Core Data database
        let managedContext = DataBaseHelper.persistentContainer.viewContext
        
        // Request to fetch from enitity in Core data database
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SavedEvent")
        
        do{
            
            // Retrieve events from enitity
            retrievedEvents = try managedContext.fetch(fetchRequest) as! [SavedEvent]
            
            print ("\(retrievedEvents.count) saved events retrieved from DB")
            
            // Pulls eneitity attributes and appends them to event class
            for eachRetrieved in retrievedEvents{
                
                let t = eachRetrieved.title
                let ci = eachRetrieved.city_name
                let co = eachRetrieved.country_name
                let vn = eachRetrieved.venue_name
                let s = eachRetrieved.start_time
                let u = eachRetrieved.url
                
                savedEvents.append(Event(t!,ci!,co!,vn!,s!,u!)!)
            }
            
        }
        catch{
            
            // In case of failure
            print("Failed to fetch saved events, reason: \(error)")
            savedEvents.append(Event("<<No saved events>>", "N/A","N/A","N/A","N/A","N/A")!)
        }
        return savedEvents
        
    }
}

class Event
{
    // Event attributes
    private (set)var title:String
    private (set)var city_name:String
    private (set)var country_name:String
    private (set)var venue_name:String
    private (set)var start_time:String
    private (set)var url:String
    private (set)var isSaved:Bool
    
    init?(_ t:String, _ ci:String, _ co:String, _ vn:String, _ s:String, _ u:String)
    {
        
        // Does not create event if certain attributes are missing
        if ((t == "") || (vn == "") || (s == ""))
        {
            return nil
        }
        else
        {
            title = t
            city_name = ci
            country_name = co
            venue_name = vn
            start_time = s
            url = u
            isSaved = false
        }
    }
    
    convenience init(_ JSONObject:[String:Any])
    {
        
        // Takes JSON objects and makes them event attributes
        let title = JSONObject["title"] as! String
        let city = JSONObject["city_name"] as! String
        let country = JSONObject["country_name"] as! String
        let venue = JSONObject["venue_name"] as! String
        let time = JSONObject["start_time"] as! String
        let url = JSONObject["url"] as! String
        
        self.init(title,city,country,venue,time,url)!
    }
    
    // To save an event
    func Save(_ save:Bool){
        
        // Access Core Data database
        let managedContext = DataBaseHelper.persistentContainer.viewContext
        
        // Access enitity
        let entity = NSEntityDescription.entity(forEntityName: "SavedEvent", in: managedContext)
        
        // New managed object        
        let savedEvent = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        // Sets new values to entity from event attributes
        savedEvent.setValue(self.title, forKeyPath: "title")
        savedEvent.setValue(self.city_name, forKeyPath: "city_name")
        savedEvent.setValue(self.country_name, forKeyPath: "country_name")
        savedEvent.setValue(self.venue_name, forKeyPath: "venue_name")
        savedEvent.setValue(self.start_time, forKeyPath: "start_time")
        savedEvent.setValue(self.url, forKeyPath: "url")
        
        if (save){
        
            do{
                
                // Save to context if saved
                try managedContext.save()
                isSaved = true
                print("\(title) was added to saved events")
            }
            catch let error as NSError{
                
                // In case of save failure
                print("Could not save event. Reason: \(error), \(error.userInfo)")
            }
        }
        else
        {
            
            // Deletes current event from Core Data
            // Fetches from entity
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedEvent")
            
            // Checks events using URL
            fetchRequest.predicate = NSPredicate(format: "url==%@", url)
                
            do{
                
                // Finds results in database
                let resultData = try managedContext.fetch(fetchRequest) as! [SavedEvent]
                print("Found \(resultData.count) records to delete")
                    
                for object in resultData{
                    
                    // Deletes event object from results
                    managedContext.delete(object)
                    print("\(title) was removed from DB")
                }
                
                // Updates boolean attribute to false
                try! managedContext.save()
                self.isSaved = false
            }
            catch{
                
                // In case of DB access failure
                print("Could not find any records to delete")
            }
        }
    }
        
    func displayEvent()->String
    {
        let strEvent = "\(title) will take place at \(venue_name)"
        return strEvent
    }
        
}


class EventService:Operation
{
    
    // Checks for URL
    var urlReceived: URL?
    
    // Checks for JSON
    var jsonFromResponse: [String:Any]?
    
    // Initialised URL as string and checks formatting
    init(_ incomingURLString:String)
    {
        urlReceived = URL(string: incomingURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
    }
    
    override func main()
    {
        
        // Checks for data
        var responseData:Data?
        
        do
        {
            
            // Performs a service call and prints response data
            responseData = try Data(contentsOf: urlReceived!)
            print("Service call (request) successful! Returned: \(responseData)")
        }
        catch
        {
            // In case of failure
            print("Service call (request) failed")
        }
        
        do
        {
            
            // Serialises JSON data and prints it to console
            jsonFromResponse = try JSONSerialization.jsonObject(with: responseData!,options: .allowFragments) as? [String:Any]
            print("JSON Parser successful. Returned: \(jsonFromResponse!)")
        }
        catch
        {
            print("JSON Parser failed")
        }
    }
}

// Class for Core Data database
class DataBaseHelper{
    
    // Creates a Core Data persistent container
    static var persistentContainer: NSPersistentContainer = {
        
        // References the data model
        let container = NSPersistentContainer(name: "SavedEvents")
        
        // Loads storage
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // Returns database
        return container
    }()
    
    static func saveContext(){
        
        // Saves the database whenever something is changed
        let context = persistentContainer.viewContext
        if context.hasChanges{
            do{
                
                try context.save()
            }
            catch{
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
