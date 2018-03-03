//
//  SavedCreatedEventsController.swift
//  Events Application
//
//  Created by Kristian Curcic on 10/01/2018.
//  Copyright © 2018 Kristian Curcic. All rights reserved.
//

import UIKit

class SavedCreatedEventsController: UITableViewController{
    
    // Cell idenifier
    private let reuseIdentifier = "CreatedEventsCell"
    
    var createdEvents:[CreatedEvent] = []
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.fetchCreatedEvents()
        print("Saved events: \(createdEvents)")
        self.tableView?.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Returns the amount of rows equal to the amount of events in Core Data   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return createdEvents.count
    }

    // Function to load info into cell labels from JSON
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CreatedEventsCell

        cell.crTitleLbl.text = createdEvents[indexPath.row].titleTxt
        cell.crTimeLbl.text = createdEvents[indexPath.row].timeTxt
        cell.crVenueLbl.text = createdEvents[indexPath.row].venueTxt
        
        return cell
    }
    
    // Function to load events from Core Data
    func fetchCreatedEvents(){
    
        let managedContext = DataBaseHelper.persistentContainer.viewContext
        
        do
        {
            createdEvents = try managedContext.fetch(CreatedEvent.fetchRequest())
        }
        catch
        {
        
            print(error)
        }
    }

    // Makes sure info is sent to next view when cell is clicked
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destVC = segue.destination as! CreatedEventController
        
        let selectedEventIndex = self.tableView.indexPathForSelectedRow?.row
        
        destVC.selectedEvent = createdEvents[selectedEventIndex!]
    }

}
