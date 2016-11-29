//
//  Netz.swift
//  SwiftStarter
//
//  Created by Ruedi Heimlicher on 30.10.2014.
//  Copyright (c) 2014 Ruedi Heimlicher. All rights reserved.
//

import Cocoa
import Foundation
import AVFoundation
import Darwin

// SPI
var						spistatus=0;

//#define TIMER0_STARTWERT					0x80
//#define SPI_BUFSIZE							48
let TIMER0_STARTWERT			=		0x80
let SPI_BUFSIZE		=					48
let BUFFER_SIZE:Int   = Int(BufferSize())


open class usb_teensy: NSObject
{
   var hid_usbstatus: Int32 = 0
   var usb_count: UInt8 = 0
   //let size = BufferSize()
 //  let size = BUFFER_SIZE
   var read_byteArray = [UInt8](repeating: 0x00, count: BUFFER_SIZE)
   var last_read_byteArray = [UInt8](repeating: 0x00, count: BUFFER_SIZE)
  /*
   char*      sendbuffer;
   sendbuffer=malloc(USB_DATENBREITE);
*/
   var write_byteArray: Array<UInt8> = Array(repeating: 0x00, count: BUFFER_SIZE)
  
   
   // var testArray = [UInt8]()
   var testArray: Array<UInt8>  = [0xAB,0xDC,0x69,0x66,0x74,0x73,0x6f,0x64,0x61]
   
   var read_OK:ObjCBool = false
   
   var new_Data:ObjCBool = false
   
   var manustring:String = ""
   var prodstring:String = ""
   
   var datatruecounter = 0
   var datafalsecounter = 0
   
   
   override init()
   {
      super.init()
   }
   
   
   open func USBOpen()->Int32
   {
      var r:Int32 = 0
      
      let    out = rawhid_open(1, 0x16C0, 0x0480, 0xFFAB, 0x0200)
      print("func usb_teensy.USBOpen out: \(out)")
      
      hid_usbstatus = out as Int32;
      
      if (out <= 0)
      {
         //NSLog(@"USBOpen: no rawhid device found");
         //[AVR setUSB_Device_Status:0];
      }
      else
      {
         NSLog("USBOpen: found rawhid device hid_usbstatus: %d",hid_usbstatus)
         /*
          let manu   = get_manu()
          let manustr = UnsafePointer<CUnsignedChar>(manu)
          if (manustr == nil)
          {
          manustring = "-"
          }
          else
          {
          manustring = String(cString: UnsafePointer<CChar>(manustr!))
          }
          */
         // https://codedump.io/share/77b7p4vSpwaJ/1/converting-from-const-char-to-swift-string
         let manu   = get_manu()
         let l = strlen(manu)
         let str1 = String(cString: get_manu())
         
         let str2 = String(cString: manu!)
         print ("manu l: \(l) \(manu)")
         if (strlen(manu) > 1)
         {
            let manustr:String = String(cString: manu!)
            manustring = String(cString: manu!)
         }
         else
         {
            manustring = "-"
         }
         
         
         
         /*
          let prod = get_prod();
          //fprintf(stderr,"prod: %s\n",prod);
          let prodstr = UnsafePointer<CUnsignedChar>(prod)
          if (prodstr == nil)
          {
          prodstring = "-"
          }
          else
          {
          prodstring = String(cString: UnsafePointer<CChar>(prod!))
          }
          
          var USBDatenDic = ["prod": prod, "manu":manu]
          */
      
      
      let prod = get_prod();
      if (strlen(prod) > 1)
      {
         //fprintf(stderr,"prod: %s\n",pr#>);
         let prodstr = String(cString: prod!)
         prodstring = String(cString: prod!)

      }
      else
      {
         prodstring = String(cString: UnsafePointer<CChar>(prod!))
      }
      
      var USBDatenDic = ["prod": prod, "manu":manu]
      
      }
      return out;
   } // end USBOpen
   
   open func manufactorer()->String?
   {
      return manustring
   }

   open func producer()->String?
   {
      return prodstring
   }
   
   

   
   
   open func status()->Int32
   {
      return hid_usbstatus
   }
   
   open func start_read_USB(_ cont: Bool)-> Int
   {
      read_OK = true
      let timerDic:NSMutableDictionary  = ["count": 0]
      
      let result = rawhid_recv(0, &read_byteArray, Int32(BUFFER_SIZE), 50);
      
      print("*report_start_read_USB result: \(result)")
      print("read_byteArray start: *\(read_byteArray)*")
      
      // var somethingToPass = "It worked in teensy_send_USB"
      let xcont = true;
      
      if (xcont == true)
      {
         var timer : Timer? = nil
         timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(usb_teensy.cont_read_USB(_:)), userInfo: timerDic, repeats: true)
      }
      return Int(result) //timerDic as NSDictionary
   }
   
   
   open func cont_read_USB(_ timer: Timer)
   {
      //print("*cont_read_USB")
      if (read_OK).boolValue
      {
         //var tempbyteArray = [UInt8](count: 32, repeatedValue: 0x00)
         
         var result = rawhid_recv(0, &read_byteArray, Int32(BUFFER_SIZE), 50)
         
         //println("*cont_read_USB result: \(result)")
         //println("tempbyteArray in Timer: *\(read_byteArray)*")
         // var timerdic: [String: Int]
         
         /*
          if  var dic = timer.userInfo as? NSMutableDictionary
          {
          if var count:Int = timer.userInfo?["count"] as? Int
          {
          count = count + 1
          dic["count"] = count
          //dic["nr"] = count+2
          //println(dic)
          usb_count += 1
          }
          }
          */
         //      let timerdic:Dictionary<String,Int!> = timer.userInfo as Dictionary<String,Int!>
         //let messageString = userInfo["message"]
         //       var tempcount = timerdic["count"]!
         
         //timer.userInfo["count"] = tempcount + 1
         
         //print("+++ new read_byteArray in Timer:")
         /*
          for  i in 0...12
          {
          print(" \(read_byteArray[i])")
          }
          println()
          for  i in 0...12
          {
          print(" \(last_read_byteArray[i])")
          }
          println()
          println()
          */
         
         
         
         //timerdic["count"] = 2
         
         // var count:Int = timerdic["count"]
         
         //timer.userInfo["count"] = count+1
         if !(last_read_byteArray == read_byteArray)
         {
            last_read_byteArray = read_byteArray
            new_Data = true
            datatruecounter += 1
            print("+++\t\tnewData in usb.swift cont_Read: \(read_byteArray[0])")
 //           print("\(read_byteArray)")
            
            
            // http://dev.iachieved.it/iachievedit/notifications-and-userinfo-with-swift-3-0/
             let nc = NotificationCenter.default
             nc.post(name:Notification.Name(rawValue:"newdata"),
             object: nil,
             userInfo: ["message":"neue Daten", "data":read_byteArray])
            
           // print("+ new read_byteArray in Timer:", terminator: "")
            for  i in 0...31
            {
              // print(" \(read_byteArray[i])", terminator: "")
            }
            //print("")
            let stL = NSString(format:"%2X", read_byteArray[0]) as String
            //print(" * \(stL)", terminator: "")
            let stH = NSString(format:"%2X", read_byteArray[1]) as String
            //print(" * \(stH)", terminator: "")
            
            //var resultat:UInt32 = UInt32(read_byteArray[1])
            //resultat   <<= 8
            //resultat    += UInt32(read_byteArray[0])
            //print(" Wert von 0,1: \(resultat) ")
            
            //print("")
            //var st = NSString(format:"%2X", n) as String
         }
         else
         {
            //new_Data = false
            datafalsecounter += 1
            //print("--- \(read_byteArray[0])\t\(datafalsecounter)")
         }
         //println("*read_USB in Timer result: \(result)")
         
         //let theStringToPrint = timer.userInfo as String
         //println(theStringToPrint)
      }
      else
      {
         timer.invalidate()
      }
   }
   
   open func stop_read_USB(_ inTimer: Timer)
   {
      read_OK = false
   }


   
   open func start_write_USB()->Int32
   {
      // http://www.swiftsoda.com/swift-coding/get-bytes-from-nsdata/
      // Test Array to generate some Test Data
      //  var testData = NSData(bytes: testArray,length: testArray.count)
     
      /*
      write_byteArray[0] = testArray[0]
      write_byteArray[1] = testArray[1]
      write_byteArray[2] = testArray[2]
      write_byteArray[3] = usb_count
 */
      write_byteArray[4] = usb_count
      if (usb_count < 0xFF)
      {
      usb_count += 1
      }
      else
      {
         usb_count = 0
      }
      
      //data0.intValue = write_byteArray[0]
      /*
      if testArray[0] < 0x80
      {
         testArray[0] += 1
      }
      else{
         testArray[0] = 0
      }

      if testArray[1] < 0x80
      {
         testArray[1] += 17
      }
      else
      {
         testArray[1] = 0
      }

      if testArray[2] < 0x80
      {
         testArray[2] += 23
      }
      else
      {
         testArray[2] = 0
      }
*/
      
      //println("write_byteArray: \(write_byteArray)")
      write_byteArray[6] = 43;
      write_byteArray[7] = 44;

      print("usb.swift new write_byteArray in start_write_USB: ", terminator: "")
      var i=0;
      
      //for  i in 0...63
      while i < 32
      {
         print(" \(write_byteArray[i])", terminator: "")
         i = i+1
      }
      print("")
      
      let dateA = Date()
      
        let senderfolg = rawhid_send(0,&write_byteArray, Int32(BUFFER_SIZE), 500)
    
      
      let dauer1 = Date() //
      
      let diff =  (dauer1.timeIntervalSince(dateA))*1000
      print("dauer rawhid_send: \(diff)")

      
      print("\tsenderfolg: \(senderfolg)", terminator: "")
      print("")
      if hid_usbstatus == 0
      {
         
      }
      else
      {
         
         
         
      }
      
      return senderfolg
      
   }
 
   //public func read_byteArray()->

   open func cont_write_USB()->Int32
   {
      //write_byteArray[3] = packetcount
      print("*** cont_write_USB packetcount: \(write_byteArray[3])\n\twrite_byteArray: ", terminator: "")
      var i=0;
      
      //for  i in 0...63
      while i < 32
      {
         print(" \(write_byteArray[i])", terminator: "")
         i = i+1
      }
      print("")

      
      let senderfolg = rawhid_send(0,&write_byteArray, Int32(BUFFER_SIZE), 500)
      
      
      return senderfolg
   }

   
} // class



open class Hello
{
   open func setU()
   {
   print("Hi Netzteil")
   }
}

