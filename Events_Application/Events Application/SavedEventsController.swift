//
//  SavedEventsController.swift
//  Events Application
//
//  Created by Kristian Curcic on 12/12/2017.
//  Copyright © 2017 Kristian Curcic. All rights reserved.
//

import UIKit

class SavedEventsController: UITableViewController {
    
    // Cell identifier
    private let reuseIdentifier = "SavedEventsCell"
    
    // Get saved events from Core Data
    var savedEvents = EventList.getSavedEvents()
    
    // Loads events into table from Core Data database
    override func viewWillAppear(_ animated: Bool)
    {
        savedEvents = EventList.getSavedEvents()
        print("Saved events: \(savedEvents)")
        self.tableView?.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Returns the amount of rows equal to the amount of events saved in Core Data
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedEvents.count
    }
    
    // Function to load info into cell labels from events saved Core Data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SavedEventsCell
        print(indexPath.row)
        cell.SavedTitleLbl.text = savedEvents[indexPath.row].title
        cell.SavedTimeLbl.text = savedEvents[indexPath.row].start_time
        cell.SavedVenueLbl.text = savedEvents[indexPath.row].venue_name
        
        return cell
    }
    
    // Makes sure info is sent to next view when cell is clicked    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destVC = segue.destination as! SavedEventsViewController
        
        let selectedEventIndex = self.tableView.indexPathForSelectedRow?.row
        
        destVC.selectedEvent = savedEvents[selectedEventIndex!]
    }
    
}
