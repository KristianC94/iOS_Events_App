//
//  EventViewController.swift
//  Events Application
//
//  Created by Kristian Curcic on 07/12/2017.
//  Copyright © 2017 Kristian Curcic. All rights reserved.
//

import UIKit
import Social
import EventKit

class EventViewController: UIViewController {
    
    // Initialises labels in the view controller
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var CityLbl: UILabel!
    @IBOutlet weak var CountryLbL: UILabel!
    @IBOutlet weak var VenueLbl: UILabel!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var UrlLbl: UILabel!
    
    
    @IBOutlet weak var saveLbl: UILabel!
    
    
    @IBAction func saveSwitch(_ sender: UISwitch) {
        
        // If switch is turned on, event is saved and SaveLbl text is changed
        if (sender .isOn == true){
            
            selectedEvent?.Save(true)
            saveLbl.text = "Saved event"
        }
            
            // If switch is turned off, event is removed from Core Data and SaveLbl text is changed
        else{
            
            selectedEvent?.Save(false)
            saveLbl.text = "Save event?"
        }
        
    }
    
    // Creates variable selectedEvent using info from Event selected in Search Table View Controller
    var selectedEvent:Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loads info from the selected event to labels
        TitleLbl.text = selectedEvent?.title
        CityLbl.text = selectedEvent?.city_name
        CountryLbL.text = selectedEvent?.country_name
        VenueLbl.text = selectedEvent?.venue_name
        TimeLbl.text = selectedEvent?.start_time
        UrlLbl.text = selectedEvent?.url
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Makes sure clicking chevron nexr to URL shows Web View
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destVC = segue.destination as! WebViewController
        
        let selectedEvent = self.selectedEvent!
        print("\(selectedEvent)")
        destVC.recievedEvent = selectedEvent
    }
    
    @IBAction func FBPostButton(_ sender: UIButton) {
        
        // Opens actions action sheet at bottom of view with Twitter & Facebook share buttons
        let actionSheet = UIAlertController(title: "Post to Social Media", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // Twitter share button
        let tweetAction = UIAlertAction(title: "Share on Twitter", style: UIAlertActionStyle.default) { (action) -> Void in
            
            // Checks to see if there is an account logged in
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
                
                // Displays view where user can compose text
                let twitterComposeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                
                // Sets text saying user is going to event title at venue name
                twitterComposeVC?.setInitialText("I am going to \((self.selectedEvent?.title)!) at \((self.selectedEvent?.venue_name)!)! \n\((self.selectedEvent?.url)!)")
                
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
                facebookComposeVC?.setInitialText("I am going to \((self.selectedEvent?.title)!) at \((self.selectedEvent?.venue_name)!)! \n\((self.selectedEvent?.url)!)")
                
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
    
    @IBAction func CalPostButton(_ sender: UIButton) {
        
        // Method to get date string from selected event and convert to date
        // Gets date string from selected event
        let dateString = "\((selectedEvent?.start_time)!)"
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
        addEventToCalendar(title: (selectedEvent?.title)!, startDate: newDate!, endDate: newDate! + 60*60, notes: (selectedEvent?.url)!, location: "\((selectedEvent?.venue_name)!), \((selectedEvent?.city_name)!), \((selectedEvent?.country_name)!)")
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
                
                let passAlert = UIAlertController(title: "Saved", message: "\((self.selectedEvent?.title)!) successfully saved to calendar", preferredStyle: .alert)
                
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
