//
//  SearchEventsViewController.swift
//  Events Application
//
//  Created by Kristian Curcic on 30/11/2017.
//  Copyright © 2017 Kristian Curcic. All rights reserved.
//

import Foundation
import UIKit

class SearchEventsViewController: UITableViewController {
    
    let reuseIdentifier = "SearchEventCell"
    
    let events:[Event] = EventList.getEventsFromWebService()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return events.count
    
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EventsCell
        print(indexPath.row)
        cell.TitleLbl.text = events[indexPath.row].title
        cell.TimeLbl.text = events[indexPath.row].start_time
        cell.VenueLbl.text = events[indexPath.row].venue_name
        
        return cell
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
