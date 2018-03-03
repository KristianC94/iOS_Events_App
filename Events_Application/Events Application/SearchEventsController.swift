//
//  SearchEventsController.swift
//  Events Application
//
//  Created by Kristian Curcic on 07/12/2017.
//  Copyright © 2017 Kristian Curcic. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    // Cell identifier
    let reuseIdentifier = "EventsCell"
    
    // Makes first API call using search term 'concert' when view is loaded
    var events:[Event] = EventList.getEventsFromWebService("api.eventful.com", "concert")
    
    @IBOutlet weak var EventSearch: UISearchBar!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        // Makes the search term whatever the user types into the search bar
        let searchTerm = searchBar.text
        print("Search term is: \(searchTerm)")
        
        // Loads events from the JSON created using the new search term
        events = EventList.getEventsFromWebService("api.eventful.com", searchTerm!)
        
        // Reloads table view to display new events
        self.tableView.reloadData()
        searchBar.resignFirstResponder() 
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Returns the amount of rows equal to the amount of events in JSON
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    // Function to load info into cell labels from JSON
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EventsCell
        print(indexPath.row)
        cell.TitleLbl.text = events[indexPath.row].title
        cell.TimeLbl.text = events[indexPath.row].start_time
        cell.VenueLbl.text = events[indexPath.row].venue_name
        
        return cell
    }
    
    // Makes sure info is sent to next view when cell is clicked
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
        let destVC = segue.destination as! EventViewController
        
        let selectedEventIndex = self.tableView.indexPathForSelectedRow?.row
        
        destVC.selectedEvent = events[selectedEventIndex!]
     }
    
}
