//
//  CreatedEventController.swift
//  Events Application
//
//  Created by Kristian Curcic on 14/12/2017.
//  Copyright © 2017 Kristian Curcic. All rights reserved.
//

import UIKit
import Social
import EventKit
import CoreData

class CreatedEventController: UIViewController {

    // Initialises labels in the view controller
    @IBOutlet weak var CrTitleLbl: UILabel!
    @IBOutlet weak var CrCityLbl: UILabel!
    @IBOutlet weak var CrCountryLbl: UILabel!
    @IBOutlet weak var CrVenueLbl: UILabel!
    @IBOutlet weak var CrTimeLbl: UILabel!
    @IBOutlet weak var CrUrlLbl: UILabel!
    
    let managedContext = DataBaseHelper.persistentContainer.viewContext
        
    @IBOutlet weak var saveLbl: UILabel!
    
    @IBAction func saveSwitch(_ sender: UISwitch) {
        
        if(sender.isOn == true)
        {
            
            // Saves current event
            // Can only be done if event is deleted first, so takes values from label text
            let entity = NSEntityDescription.entity(forEntityName: "CreatedEvent", in: managedContext)
            
            let createdEvent = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            createdEvent.setValue(CrTitleLbl!.text, forKeyPath: "titleTxt")
            createdEvent.setValue(CrCityLbl!.text, forKeyPath: "cityTxt")
            createdEvent.setValue(CrCountryLbl!.text, forKeyPath: "countryTxt")
            createdEvent.setValue(CrVenueLbl!.text, forKeyPath: "venueTxt")
            createdEvent.setValue(CrTimeLbl!.text, forKeyPath: "timeTxt")
            createdEvent.setValue(CrUrlLbl!.text, forKeyPath: "urlTxt")
            
            do{
                
                try managedContext.save()
                print("\(selectedEvent) was added to saved events")
            }
            catch let error as NSError{
                
                print("Could not save event. Reason: \(error), \(error.userInfo)")
            }
            
            saveLbl.text = "Saved Event"
        }
        else
        {
            // Deletes current event from Core Data
            // Fetches from entity            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CreatedEvent")
            
            // Checks events using title          
            fetchRequest.predicate = NSPredicate(format: "titleTxt==%@", (selectedEvent?.titleTxt!)!)
            
            do{
                
                // Finds results in database                
                let resultData = try managedContext.fetch(fetchRequest) as! [CreatedEvent]
                print("Found \(resultData.count) records to delete")
                
                for object in resultData{
                    
                    // Deletes event object from results                    
                    managedContext.delete(object)
                    print("\(selectedEvent?.titleTxt) was removed from DB")
                }
                
                //try! managedContext.save()
            }
            catch{
                
                // In case of DB access failure                
                print("Could not find any records to delete")
            }
            
            saveLbl.text = "Save Event?"
            
        }
    }
    
    // String variables for event info
    var CrTitle, CrCity, CrCountry, CrVenue, CrTime, CrUrl : String!
    
    var selectedEvent:CreatedEvent?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sends label text to string variables
        CrTitleLbl.text = selectedEvent?.titleTxt
        CrCityLbl.text = selectedEvent?.cityTxt
        CrCountryLbl.text = selectedEvent?.countryTxt
        CrVenueLbl.text = selectedEvent?.venueTxt
        CrTimeLbl.text = selectedEvent?.timeTxt
        CrUrlLbl.text = selectedEvent?.urlTxt

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Makes sure clicking chevron nexr to URL shows Web View
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destVC = segue.destination as! WebViewController2
        
        let createdURL = selectedEvent?.urlTxt
        print("\(createdURL)")
        destVC.newURL = createdURL!
    }
    
    @IBAction func smPostButton(_ sender: UIButton) {
        
        // Opens actions action sheet at bottom of view with Twitter & Facebook share buttons
        let actionSheet = UIAlertController(title: "Post to Social Media", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // Twitter share button
        let tweetAction = UIAlertAction(title: "Share on Twitter", style: UIAlertActionStyle.default) { (action) -> Void in
            
            // Checks to see if there is an account logged in
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
                
                // Displays view where user can compose text
                let twitterComposeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                
                // Sets text saying user is going to event title at venue name
                twitterComposeVC?.setInitialText("I am going to \((self.CrTitleLbl.text)!) at \((self.CrVenueLbl.text)!)! \n\((self.CrUrlLbl.text)!)")
                
                self.present(twitterComposeVC!, animated: true, completion: nil)
            }
            else {
                
                // Tells user they need to login to their Twitter account if they haven't already
                let alert = UIAlertController(title: "Not logged in", message: "Please login to your Twitter account on the Twitter app or in the phone settings", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
        // Facebook share button
        let fbAction = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.default) { (action) -> Void in
            
            // Checks to see if there is an account logged in
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
                
                // Displays view where user can compose text
                let facebookComposeVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                
                // Sets text saying user is going to event title at venue name
                facebookComposeVC?.setInitialText("I am going to \((self.CrTitleLbl.text)!) at \((self.CrVenueLbl.text)!)! \n\((self.CrUrlLbl.text)!)")
                
                self.present(facebookComposeVC!, animated: true, completion: nil)
            }
            else {
                
                // Tells user they need to login to their Facebook account if they haven't already
                let alert = UIAlertController(title: "Not logged in", message: "Please login to your Facebook account on the Facebook app or in the phone settings", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        // Closes action sheet
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (action) -> Void in
            
        }
        
        // Initialises action sheet
        actionSheet.addAction(fbAction)
        actionSheet.addAction(tweetAction)
        actionSheet.addAction(closeAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
        
    @IBAction func calPostButton(_ sender: UIButton) {
        
        // Method to get date string from event and convert to date
        // Gets date string from Time variable
        let dateString = "\((self.CrTimeLbl.text)!)"
        print(dateString)
        
        // Instantiates date formatter and sets date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // Creates date from date string and puts it into the above format
        let date = dateFormatter.date(from: dateString)!
        
        // Instantiates current calendar and uses it to get selected components from the date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        // Creates a new date from just the components selected above
        let newDate = calendar.date(from:components)
        print(newDate!)
    
        // Runs below function with event details added in
        addEventToCalendar(title: (self.CrTitleLbl.text)!, startDate: newDate!, endDate: newDate! + 60*60, notes: (self.CrUrlLbl.text)!, location: "\((self.CrVenueLbl.text)!), \((self.CrCityLbl.text)!), \((self.CrCountryLbl.text)!)")
    }
    
    // Function to add event to calendar
    func addEventToCalendar(title: String, startDate: Date, endDate: Date, notes: String, location: String, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil)
    {
        
        // EKEventStore is where the event is stored once saved
        let eventStorage = EKEventStore()
        
        // Permission must be granted by the user before events can be added to iOS calendar
        eventStorage.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                // If permission is granted and there are no errors accessing calendar:
                
                // Creates new event object with set parameters (title, date etc)
                let event = EKEvent(eventStore: eventStorage)
                
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.notes = notes
                event.location = location
                event.calendar = eventStorage.defaultCalendarForNewEvents // Sets which calendar event goes to
                
                do {
                    
                    // Tries to save event
                    try eventStorage.save(event, span: .thisEvent)
                    
                } catch let e as NSError {
                    
                    completion?(false, e)
                    return
                }
                
                // Event is saved to calendar and alert notifies user
                completion?(true, nil)
                
                let passAlert = UIAlertController(title: "Saved", message: "\((self.selectedEvent?.titleTxt)!) successfully saved to calendar", preferredStyle: .alert)
                
                let OkButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                passAlert.addAction(OkButton)
                
                self.present(passAlert, animated: true, completion: nil)
                
            } else {
                
                // Event is unable to be saved and alert notifies user with error message
                completion?(false, error as NSError?)
                
                let failAlert = UIAlertController(title: "Event did not save", message: (error as! NSError).localizedDescription, preferredStyle: .alert)
                
                let OkButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                failAlert.addAction(OkButton)
                
                self.present(failAlert, animated: true, completion: nil)
            }
        })
    }
    
}
