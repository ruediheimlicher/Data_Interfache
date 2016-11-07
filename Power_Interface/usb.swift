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

public class usb_teensy: NSObject
{
   var hid_usbstatus: Int32 = 0
   var usb_count: UInt8 = 0
   
   var read_byteArray = [UInt8](count: 32, repeatedValue: 0x00)
   var last_read_byteArray = [UInt8](count: 32, repeatedValue: 0x00)
  /*
   char*      sendbuffer;
   sendbuffer=malloc(USB_DATENBREITE);
*/
   var write_byteArray: Array<UInt8> = Array(count: 32, repeatedValue: 0x00)
  
  
   
   // var testArray = [UInt8]()
   var testArray: Array<UInt8>  = [0xAB,0xDC,0x69,0x66,0x74,0x73,0x6f,0x64,0x61]
   
   var read_OK:ObjCBool = false
   
   var new_Data:ObjCBool = false
   
   var manustring:String = ""
   var prodstring:String = ""
   
   override init()
   {
      super.init()
   }
   
   public func USBOpen()->Int32
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
         
         let manu   = get_manu()
         let manustr = UnsafePointer<CUnsignedChar>(manu)
         if (manustr == nil)
         {
            manustring = "-"
         }
         else
         {
            manustring = String.fromCString(UnsafePointer<CChar>(manustr))!
         }
         
         
         
         
         let prod = get_prod();
         //fprintf(stderr,"prod: %s\n",prod);
         let prodstr = UnsafePointer<CUnsignedChar>(prod)
         if (prodstr == nil)
         {
            prodstring = "-"
         }
         else
         {
            prodstring = String.fromCString(UnsafePointer<CChar>(prod))!
         }
         
         var USBDatenDic = ["prod": prod, "manu":manu]
         
      }
      
      
      return out;
   } // end USBOpen
   
   public func manufactorer()->String?
   {
      return manustring
   }

   public func producer()->String?
   {
      return prodstring
   }
   
   

   
   
   public func status()->Int32
   {
      return hid_usbstatus
   }
   
   func appendCRLFAndConvertToUTF8_1(s: String) -> NSData {
      let crlfString: NSString = s.stringByAppendingString("\r\n")
      let buffer = crlfString.UTF8String
      let bufferLength = crlfString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
      let data = NSData(bytes: buffer, length: bufferLength)
      return data;
   }
   
   public func start_read_USB()-> NSDictionary
   {
      read_OK = true
      let timerDic:NSMutableDictionary  = ["count": 0]
      
      
      let result = rawhid_recv(0, &read_byteArray, 32, 50);
      
      print("*report_start_read_USB result: \(result)")
      //println("read_byteArray nach: *\(read_byteArray)*")
   
      var somethingToPass = "It worked in teensy_send_USB"
      
      var timer : NSTimer? = nil
      timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("cont_read_USB:"), userInfo: timerDic, repeats: true)
      
      return timerDic as NSDictionary
   }
   
   
   public func cont_read_USB(timer: NSTimer)
   {
      if (read_OK)
   {
      
         //var tempbyteArray = [UInt8](count: 32, repeatedValue: 0x00)
         var result = rawhid_recv(0, &read_byteArray, 32, 50)
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
            
            print("+++ new read_byteArray in Timer:", terminator: "")
            for  i in 0...16
            {
               print(" \(read_byteArray[i])", terminator: "")
            }
            let stL = NSString(format:"%2X", read_byteArray[6]) as String
            print(" * \(stL)", terminator: "")
            let stH = NSString(format:"%2X", read_byteArray[7]) as String
            print(" * \(stH)", terminator: "")
            
            var resultat:UInt16 = UInt16(read_byteArray[7])
            resultat   <<= 8
             resultat    += UInt16(read_byteArray[6])
            print(" * \(resultat) ", terminator: "")
            
            print("")
            //var st = NSString(format:"%2X", n) as String
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

   
   public func send_USB()->Int32
   {
      // http://www.swiftsoda.com/swift-coding/get-bytes-from-nsdata/
      // Test Array to generate some Test Data
      //  var testData = NSData(bytes: testArray,length: testArray.count)
      
      write_byteArray[0] = testArray[0]
      write_byteArray[1] = testArray[1]
      write_byteArray[2] = testArray[2]
      write_byteArray[3] = usb_count
      usb_count += 1
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

      
      //println("write_byteArray: \(write_byteArray)")
      print("new write_byteArray in send_USB: ", terminator: "")
      
      for  i in 0...16
      {
         print(" \(write_byteArray[i])")
      }
      
      
      let senderfolg = rawhid_send(0,&write_byteArray, 32, 50)
      
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

   
   public func rep_read_USB(inTimer: NSTimer)
   {
         
         
         
         
   }
   
}


public class Hello
{
   public func setU()
   {
   print("Hi Netzteil")
   }
}

