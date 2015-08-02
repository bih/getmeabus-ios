//
//  TimetableController.swift
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
import QuartzCore

class TimetableController : UIViewController {
    var stopName : String!
    var atcoCode : String!
    
    @IBOutlet var tableContainer: UIView!
    @IBOutlet var stopTitle: UILabel!
    
    override func viewDidLoad() {
        updateTitle()
    }
    
    func updateTitle() {
        self.stopTitle.text = "Selected stop: \(stopName)\nShowing bus times from \(getHourMin())"
    }
    
    func getHourMin() -> String {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        var hour = components.hour
        var minutes = components.minute
        var hourText = "\(hour)"
        var minText = "\(minutes)"
        
        if hour < 10 { hourText = "0\(hour)" }
        if minutes < 10 { minText = "0\(minutes)" }
        
        return "\(hourText):\(minText)"
    }
}