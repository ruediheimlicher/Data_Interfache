//
//  notific.swift
//  Data_Interface
//
//  Created by Ruedi Heimlicher on 22.11.2016.
//  Copyright © 2016 Ruedi Heimlicher. All rights reserved.
//

import Foundation



func test()
{
   
   let myNoti = Notification.Name(rawValue:"MyNotification")
   
  // override func viewDidLoad()
   {
 //     super.viewDidLoad()
      
      let nc = NotificationCenter.default
      nc.addObserver(forName:myNoti, object:nil, queue:nil, using:catchNotification)
   }
   
   override func viewDidAppear(_ animated: Bool)
   {
      super.viewDidAppear(animated)
      let nc = NotificationCenter.default
      nc.post(name:myNotification,
              object: nil,
              userInfo:["message":"Hello there!", "date":Date()])
   }
   
   func catchNotification(notification:Notification) -> Void
   {
      print("Catch notification")
      
      guard let userInfo = notification.userInfo,
         let message  = userInfo["message"] as? String,
         let date     = userInfo["date"]    as? Date else
      {
            print("No userInfo found in notification")
            return
      }
      
      let alert = UIAlertController(title: "Notification!",
                                    message:"\(message) received at \(date)",
         preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
   }
}
