//
//  TableController.swift
//  GetMeABus
//
//  Created by Bilawal Hameed on 01/08/2015.
//  Copyright (c) 2015 SyeefOrg. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SVProgressHUD
import QuartzCore

class TableController : UITableViewController {
    private var atcoCode : String!
    private var timetable : [JSON] = [JSON]()
    
    override func viewDidAppear(animated: Bool) {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.tintColor = UIColor.whiteColor()
        self.refreshControl!.backgroundColor = UIColor(red: 192.0 / 255.0, green: 57.0 / 255.0, blue: 43.0 / 255.0, alpha: 1.0)
        self.refreshControl!.tintColorDidChange()
        self.refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
        atcoCode = (self.parentViewController as! TimetableController).atcoCode
        getTimetable()
        
        self.refreshControl!.beginRefreshing()
        self.tableView.setContentOffset(CGPointMake(0, -self.refreshControl!.frame.size.height), animated: false)
        self.tableView.backgroundColor = UIColor(red: 250.0 / 255.0, green: 248.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timetable.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
        }
        
        let entry : JSON = timetable[indexPath.row] as JSON
        let line = entry["line"].stringValue
        let direction = entry["direction"].stringValue
        
        cell!.backgroundColor = UIColor(red: 250.0 / 255.0, green: 248.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        cell!.textLabel!.text = "\(line)"
        cell!.detailTextLabel!.text = entry["aimed_departure_time"].stringValue
        
        return cell!
    }
    
    func refresh() {
        getTimetable()
    }
    
    func getTimetable() {
        // Date (2015-8-1)
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: date)
        let dayString = "\(components.year)-\(components.month)-\(components.day)"
        
        // Hour : minute
        let hourMin = (self.parentViewController as! TimetableController).getHourMin()
        
        // Construct the url
        var url = "http://transportapi.com/v3/uk/bus/stop/\(atcoCode)/\(dayString)/\(hourMin)/timetable.json?group=no&api_key=e2c96777c715a5d317c9d2016fdf5284&app_id=b4d09e5d"
        
        Alamofire
            .request(.GET, url, parameters: nil)
            .responseSwiftyJSON({ (_, _, data : JSON, _) in
                
                self.timetable = []
                
                for (item: JSON) in data["departures"]["all"].arrayValue {
                    self.timetable.append(item)
                }
                
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
                (self.parentViewController as! TimetableController).updateTitle()
            })
    }
}