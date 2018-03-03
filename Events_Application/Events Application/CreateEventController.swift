//
//  CreateEventController.swift
//  Events Application
//
//  Created by Kristian Curcic on 13/12/2017.
//  Copyright © 2017 Kristian Curcic. All rights reserved.
//

import UIKit
import CoreData

class CreateEventController: UIViewController {
    
    // Initialises text views
    @IBOutlet weak var titleTxt: UITextField!
    @IBOutlet weak var cityTxt: UITextField!
    @IBOutlet weak var countryTxt: UITextField!
    @IBOutlet weak var venueTxt: UITextField!
    @IBOutlet weak var timeTxt: UITextField!
    @IBOutlet weak var urlTxt: UITextField!
    
    // Access to database
    let managedContext = DataBaseHelper.persistentContainer.viewContext
    
    @IBAction func SaveEventBtn(_ sender: UIButton) {
        
        // Checks if text views are empty
        if titleTxt.text!.isEmpty || cityTxt.text!.isEmpty || countryTxt.text!.isEmpty || venueTxt.text!.isEmpty ||
            timeTxt.text!.isEmpty || urlTxt.text!.isEmpty
        {
            
            // Alert tells user to populate all text views if any are empty
            let alert = UIAlertController(title: "Missing values", message: "Please populate all fields", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
                    
        }
                    
        else {
            
            // Saves event and alerts user
            print("The event title is \((titleTxt.text)!)")
            
            let passAlert = UIAlertController(title: "Saved", message: "\((titleTxt.text)!) successfully saved to created events", preferredStyle: .alert)
            
            let OkButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            passAlert.addAction(OkButton)
            
            self.present(passAlert, animated: true, completion: nil)
            
            Save(true)
        }
        
    }
    
    // Function to save event
    func Save(_ save:Bool)
    {
        // Access Core Data database
        let managedContext = DataBaseHelper.persistentContainer.viewContext
        
        // Access enitity
        let entity = NSEntityDescription.entity(forEntityName: "CreatedEvent", in: managedContext)
        
        // New managed object
        let createdEvent = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        // Sets new values to entity from text in text views
        createdEvent.setValue(titleTxt!.text, forKeyPath: "titleTxt")
        createdEvent.setValue(cityTxt!.text, forKeyPath: "cityTxt")
        createdEvent.setValue(countryTxt!.text, forKeyPath: "countryTxt")
        createdEvent.setValue(venueTxt!.text, forKeyPath: "venueTxt")
        createdEvent.setValue(timeTxt!.text, forKeyPath: "timeTxt")
        createdEvent.setValue(urlTxt!.text, forKeyPath: "urlTxt")
        
        do{
            
            // Attempts to save
            try managedContext.save()
            print("\(createdEvent) was added to saved events")
        }
        catch let error as NSError{
            
            // Displays error in case of save failure
            print("Could not save event. Reason: \(error), \(error.userInfo)")
        }
    }
}


