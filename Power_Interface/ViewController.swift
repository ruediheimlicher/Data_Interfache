//
//  ViewController.swift
//  Power_Interface
//
//  Created by Ruedi Heimlicher on 02.11.2014.
//  Copyright (c) 2014 Ruedi Heimlicher. All rights reserved.
//

import Cocoa
import AVFoundation


class ViewController: NSViewController 
{
   
   // var  myUSBController:USBController
   // var usbzugang:
   var usbstatus: Int32 = 0
   
   var usb_read_cont = false; // kontinuierlich lesen
   var usb_write_cont = false; // kontinuierlich schreiben
   
   var teensy = usb_teensy()
   
   var teensycode:UInt8 = 0
   
   var spistatus:UInt8 = 0;
   
   @IBOutlet weak var manufactorer: NSTextField!
   @IBOutlet weak var Counter: NSTextField!
   
   @IBOutlet weak var Start: NSButton!
   
   @IBOutlet weak var inputFeld: NSTextField!
   
   @IBOutlet weak var USB_OK: NSTextField!
   
   @IBOutlet weak var start_read_USB_Knopf: NSButton!
   @IBOutlet weak var stop_read_USB_Knopf: NSButton!
   
   @IBOutlet weak var start_write_USB_Knopf: NSButton!
   @IBOutlet weak var stop_write_USB_Knopf: NSButton!
   
   
   @IBOutlet weak var codeFeld: NSTextField!
   
   @IBOutlet weak var data0: NSTextField!
   
   @IBOutlet weak var data1: NSTextField!
   
   @IBOutlet  var input: NSTextView!

   @IBOutlet weak var data2: NSTextField!
   @IBOutlet weak var data3: NSTextField!
   
   
   @IBOutlet weak var H_Feld: NSTextField!
   
   @IBOutlet weak var L_Feld: NSTextField!
   
   @IBOutlet weak var spannungsanzeige: NSSlider!
   @IBOutlet weak var extspannungFeld: NSTextField!
   
   @IBOutlet weak var spL: NSTextField!
   @IBOutlet weak var spH: NSTextField!
   
   @IBOutlet weak var extstrom: NSTextField!
   @IBOutlet weak var Teensy_Status: NSButton!
   
   @IBOutlet weak var cont_write_check: NSButton!
   
   @IBOutlet weak var extspannungStepper: NSStepper!
   
   
   @IBAction func report_cont_write(sender: AnyObject)
   {
      if (sender.state == 0)
      {
         usb_write_cont = false
      }
      else
      {
         usb_write_cont = true
      }
      //println("report_cont_write usb_write_cont: \(usb_write_cont)")
   }
   @IBAction func controlDidChange(sender: AnyObject)
   {
      print("controlDidChange: \(sender.doubleValue)")
      self.update_extspannung(sender.doubleValue)
      self.setSpannung()
   }
   
   
   @IBAction func sendSpannung(sender: AnyObject)
   {
 
      var formatter = NSNumberFormatter()
      var tempspannung:Double  = extspannungFeld.doubleValue * 100
      if (tempspannung > 3000)
      {
         tempspannung = 3000
         
        
      }
//      extspannungFeld.doubleValue = ((tempspannung/100)+1)%12
      var tempintspannung = UInt16(tempspannung)
      //NSString(format:"%2X", a2)
      spL.stringValue = NSString(format:"%02X", (tempintspannung & 0x00FF)) as String
      spH.stringValue = NSString(format:"%02X", ((tempintspannung & 0xFF00)>>8)) as String
      print("tempintspannung L: \(spL.stringValue)\ttempintspannung H: \(spH.stringValue) ")
      teensy.write_byteArray[0] = 0x01
      print("write_byteArray 0: \(teensy.write_byteArray[0])")
      teensy.write_byteArray[1] = UInt8(tempintspannung & (0x00FF))
      teensy.write_byteArray[2] = UInt8((tempintspannung & (0xFF00))>>8)
      
      var senderfolg = teensy.send_USB()
      teensy.write_byteArray[0] = 0x00 // bit 0 zuruecksetzen
      //senderfolg = teensy.send_USB()
   }
 
   func setSpannung()
   {
      var beepSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beep", ofType: "aif")!)
      
      
      var formatter = NSNumberFormatter()
      var tempspannung:Double  = extspannungFeld.doubleValue * 100
      if (tempspannung > 3000)
      {
         tempspannung = 3000
         
         
      }
      //      extspannungFeld.doubleValue = ((tempspannung/100)+1)%12
      var tempintspannung = UInt16(tempspannung)
      //NSString(format:"%2X", a2)
      spL.stringValue = NSString(format:"%02X", (tempintspannung & 0x00FF)) as String
      spH.stringValue = NSString(format:"%02X", ((tempintspannung & 0xFF00)>>8)) as String
      print("tempintspannung L: \(spL.stringValue)\ttempintspannung H: \(spH.stringValue) ")
      teensy.write_byteArray[0] = 0x01
      print("write_byteArray 0: \(teensy.write_byteArray[0])")
      teensy.write_byteArray[1] = UInt8(tempintspannung & (0x00FF))
      teensy.write_byteArray[2] = UInt8((tempintspannung & (0xFF00))>>8)
      
      var senderfolg = teensy.send_USB()
      teensy.write_byteArray[0] = 0x00 // bit 0 zuruecksetzen
      //senderfolg = teensy.send_USB()
   }

   
   
   @IBAction func sendStrom(sender: AnyObject)
   {
      var formatter = NSNumberFormatter()
      var tempstrom:Double  = extstrom.doubleValue * 100
      if (tempstrom > 3000)
      {
         tempstrom = 3000
         
      }
      var ired = NSString(format:"%2.2f", tempstrom/100)
      extstrom.stringValue = ired as String
      var tempintstrom = UInt16(tempstrom)
      //NSString(format:"%2X", a2)
      spL.stringValue = NSString(format:"%02X", (tempintstrom & 0x00FF)) as String
      spH.stringValue = NSString(format:"%02X", ((tempintstrom & 0xFF00)>>8)) as String
      print("tempintstrom L: \(spL.stringValue)\ttempintstrom H: \(spH.stringValue) ")
      teensy.write_byteArray[0] = 0x02
      print("write_byteArray 0: \(teensy.write_byteArray[0])")
      teensy.write_byteArray[1] = UInt8(tempintstrom & (0x00FF))
      teensy.write_byteArray[2] = UInt8((tempintstrom & (0xFF00))>>8)
      
      var senderfolg = teensy.send_USB()
      teensy.write_byteArray[0] = 0x00
   }
   
   
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.USBfertigAktion(_:)), name: "NSWindowWillCloseNotification", object: nil)

      let xy = Hello()
     // USB_OK.backgroundColor = NSColor.yellowColor()
      USB_OK.textColor = NSColor.yellowColor()
       USB_OK.stringValue = "?";
      // Do any additional setup after loading the view.
      
      //spannungsanzeige.numberOfTickMarks = 16
      extspannungFeld.doubleValue = 5.0
      extspannungStepper.doubleValue = 5.0
   }
   
   
   func USBfertigAktion(sender: AnyObject)-> Bool
   {
      NSLog("USBfertigAktion will schliessen")
      
      
      teensycode &= ~(1<<7)
      teensy.write_byteArray[15] = teensycode
      teensy.write_byteArray[0] |= UInt8(Teensy_Status.intValue)
      teensy.write_byteArray[1] = UInt8(data0.intValue)
      let senderfolg = teensy.send_USB()
      if (senderfolg > 0)
      {
      return true
      }
      return false
   }
   
   
   @IBAction func startU_Funktion(sender: NSButton)
   {
      let timerDic:NSMutableDictionary = ["delta": 1.0]
      var timer : NSTimer? = nil
      timer = NSTimer.scheduledTimerWithTimeInterval(8.0, target: self, selector: Selector("cont_U_Funktion:"), userInfo: timerDic, repeats: true)

   }

   func cont_U_Funktion(timer: NSTimer)
   {
      
      var aktspannung:Double  = extspannungFeld.doubleValue
      if let timerDic = timer.userInfo as? NSMutableDictionary
      {
         var delta = timerDic["delta"] as? Int
         if (extspannungFeld.doubleValue == 10 )
         {
            delta! *= (-1)
            timerDic["delta"] = delta!
         }
         else if (extspannungFeld.doubleValue == 0 )
         {
            delta! = 1
            timerDic["delta"] = delta!
         }
         aktspannung += Double(delta!)
         extspannungFeld.doubleValue = (aktspannung )
         
         print("aktspannung: \(aktspannung)")
         teensy.write_byteArray[0] = 0x01
         //println("write_byteArray 0: \(teensy.write_byteArray[0])")
         aktspannung *= 100
         let sendspannung:Int = Int(aktspannung)
         teensy.write_byteArray[1] = UInt8(sendspannung*100 & (0x00FF))
         teensy.write_byteArray[2] = UInt8((sendspannung & (0xFF00))>>8)
         print("write_byteArray 1: \(teensy.write_byteArray[1])\t 2: \(teensy.write_byteArray[2])")
         var senderfolg = teensy.send_USB()
         teensy.write_byteArray[0] = 0x00 // bit 0 zuruecksetzen

      }
      
   }
   
   
   func tester(timer: NSTimer)
   {
      let theStringToPrint = timer.userInfo as! String
      print(theStringToPrint)
   }
   
   
   @IBAction func Teensy_setState(sender: NSButton)
   {
      if (sender.state > 0)
      {
         sender.title = "Teensy ON"
         teensycode |= (1<<7)
         teensy.write_byteArray[15] = teensycode
        // teensy.write_byteArray[0] |= UInt8(Teensy_Status.intValue)
        // teensy.write_byteArray[1] = UInt8(data0.intValue)
         
         
         var senderfolg = teensy.send_USB()

      }
      else
      {
         sender.title = "Teensy OFF"
         teensy.read_OK = false;
         //teensy.write_byteArray[15] = 0
         teensycode &= ~(1<<7)
         teensy.write_byteArray[15] = teensycode
         teensy.write_byteArray[0] |= UInt8(Teensy_Status.intValue)
         teensy.write_byteArray[1] = UInt8(data0.intValue)
         var senderfolg = teensy.send_USB()
         
      }
   }
   
   @IBAction func start_read_USB(sender: AnyObject)
   {
      print("start_read_USB")
      //myUSBController.startRead(1)
      teensy.start_read_USB()
      usb_read_cont = true // cont_Read wird aktiviert
      
      //teensy.start_teensy_Timer()
      
      //     var somethingToPass = "It worked"
      
      //      let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("tester:"), userInfo: somethingToPass, repeats: true)
      var timer : NSTimer? = nil
      
      // Auslesen der Ergebnisse in teensy
      timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.cont_read_USB(_:)), userInfo: nil, repeats: true)

   }
   
   func cont_read_USB(timer: NSTimer)
   {
      if (usb_read_cont)
      {
         //NSBeep()
         if (teensy.new_Data)
         {
            NSBeep()
            let a1: UInt8 = teensy.last_read_byteArray[6]
            let a2: UInt8 = teensy.last_read_byteArray[7]
            
  //          var data = NSData(bytes: teensy.last_read_byteArray, length: 32)
            
  //          print("\(data)")
            
           // let inputstring = teensy.last_read_byteArray as NSArray
            
            let b1: Int32 = Int32(a1)
            let b2: Int32 = Int32(a2)
            //H_Feld.intValue = b2
            H_Feld.stringValue = NSString(format:"%2X", a2) as String
           // H_Feld.stringValue = NSString(format:"%d", a2)
            
            //L_Feld.intValue = b1
           L_Feld.stringValue = NSString(format:"%2X", a1) as String
           // L_Feld.stringValue = NSString(format:"%d", a1)
            
            let rotA:Int32 = (b1 | (b2<<8))
            //inputFeld.stringValue = NSString(format:"%2X", rotA)
            inputFeld.intValue = Int32(rotA)
            
            
            spannungsanzeige.intValue = Int32(rotA )
            
            teensy.new_Data = false
         }
         
         
         
         
         //var tempbyteArray = [UInt8](count: 32, repeatedValue: 0x00)
         /*
         print("teensy read_byteArray: ")
         for  i in 0...16
         {
            print("| \(teensy.last_read_byteArray[i])")
         }
         println("|")
         */
         //println(teensy.read_byteArray)

         //println("tempbyteArray in Timer: *\(tempbyteArray)*")
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
            }
         }
        */
         
         //let timerdic:Dictionary<String,Int!> = timer.userInfo as Dictionary<String,Int!>
         //let messageString = userInfo["message"]
         //var tempcount = timerdic["count"]!
         
         //timer.userInfo["count"] = tempcount + 1
         
         
         
         
         
         //timerdic["count"] = 2
         
         // var count:Int = timerdic["count"]
         
         //timer.userInfo["count"] = count+1
         /*
         if !(teensy.last_read_byteArray == read_byteArray)
         {
            read_byteArray = last_read_byteArray
            
            print("+++ new read_byteArray in Timer:")
            for  i in 0...4
            {
               print(" \(read_byteArray[i])")
            }
            println()
            
            
         }
         */
         //println("*read_USB in Timer result: \(result)")
         
         //let theStringToPrint = timer.userInfo as String
         //println(theStringToPrint)
      }
      else
      {
         timer.invalidate()
      }
   }

   
   
   @IBAction func check_USB(sender: NSButton)
   {
      let erfolg = teensy.USBOpen()
      usbstatus = erfolg
      print("USBOpen erfolg: \(erfolg) usbstatus: \(usbstatus)")
      
      if (rawhid_status()==1)
      {
        // NSBeep()
         print("status 1")
         USB_OK.textColor = NSColor.greenColor()
         USB_OK.stringValue = "OK";
         manufactorer.stringValue = "Manufactorer: " + teensy.manufactorer()!
         
         Teensy_Status.enabled = true;
         start_read_USB_Knopf.enabled = true;
         stop_read_USB_Knopf.enabled = true;
         start_write_USB_Knopf.enabled = true;
         stop_write_USB_Knopf.enabled = true;
      }
      else
         
      {
         print("status 0")
         USB_OK.textColor = NSColor.redColor()
        USB_OK.stringValue = "X";
         Teensy_Status.enabled = false;
         start_read_USB_Knopf.enabled = false;
         stop_read_USB_Knopf.enabled = false;
         start_write_USB_Knopf.enabled = false;
         stop_write_USB_Knopf.enabled = false;

      }
      print("antwort: \(teensy.status())")
   }
   
   @IBAction func stop_read_USB(sender: AnyObject)
   {
      teensy.read_OK = false
      usb_read_cont = false
      
      
   }
   
   
   @IBAction func stop_write_USB(sender: AnyObject)
   {
      usb_write_cont = false
   }
   
   
   
   @IBAction func send_USB(sender: AnyObject)
   {
      //NSBeep()
      teensy.write_byteArray[0] |= UInt8(Teensy_Status.intValue)
      teensy.write_byteArray[1] = UInt8(data0.intValue)
      
      //var c0 = codeFeld.intValue + 1
      var c0:UInt8 = UInt8(Teensy_Status.intValue)
      c0 <<= 7
      codeFeld.intValue = Int32(c0)
      var c1 = data0.intValue + 1
      //data0.intValue = c0
      
      
      
      var senderfolg = teensy.send_USB()
      
      
      
      usb_write_cont = (cont_write_check.state == 1)
      
      //println("send_USB senderfolg: \(senderfolg)")
      
      
      /*
      var USB_Zugang = USBController()
      USB_Zugang.setKontrollIndex(5)
      
      Counter.intValue = USB_Zugang.kontrollIndex()
      
      // var  out  = 0
      
      //USB_Zugang.Alert("Hoppla")
      
      var x = getX()
      Counter.intValue = x
      
      var    out = rawhid_open(1, 0x16C0, 0x0480, 0xFFAB, 0x0200)
      
      println("send_USB out: \(out)")
      
      if (out <= 0)
      {
      usbstatus = 0
      inputFeld.stringValue = "not OK"
      println("kein USB-Device")
      }
      else
      {
      usbstatus = 1
      println("USB-Device da")
      var manu = get_manu()
      //println(manu) // ok, Zahl
      var manustring = UnsafePointer<CUnsignedChar>(manu)
      //println(manustring) // ok, Zahl
      
      let manufactorername = String.fromCString(UnsafePointer(manu))
      println("str: %s", manufactorername!)
      manufactorer.stringValue = manufactorername!
      
      /*
      var strA = ""
      strA.append(Character("d"))
      strA.append(UnicodeScalar("e"))
      println(strA)
      
      let x = manu
      let s = "manufactorer"
      println("The \(s) is \(manu)")
      var pi = 3.14159
      NSLog("PI: %.7f", pi)
      let avgTemp = 66.844322156
      println(NSString(format:"AAA: %.2f", avgTemp))
      */
      }
      */
      
      var timer : NSTimer? = nil
      timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(ViewController.cont_write_USB(_:)), userInfo: nil, repeats: true)

   }
   
 func cont_write_USB(timer: NSTimer)
 {
    //println("report_cont_write usb_write_cont: \(usb_write_cont)")
   // if (usb_write_cont)
    if (cont_write_check.state == 1)
    
    {
     
      //NSBeep()
      //teensy.write_byteArray[0] = UInt8((codeFeld.intValue)%0xff)
      //println("teensycode vor: \(teensycode)")
      
      teensycode |= UInt8((codeFeld.intValue)%0x0f)
      print("teensycode: \(teensycode)")
      teensy.write_byteArray[15] = teensycode
      teensy.write_byteArray[0] = UInt8((codeFeld.intValue)%0xff)
      
      teensy.write_byteArray[1] = UInt8((data0.intValue)%0xff)
      teensy.write_byteArray[2] = UInt8((data0.intValue)%0xff)
      teensy.write_byteArray[3] = UInt8((data0.intValue)%0xff)
      
      print("spannungsanzeige: \(spannungsanzeige.intValue)")
      
      teensy.write_byteArray[8] = UInt8((spannungsanzeige.intValue)%0xff);
      teensy.write_byteArray[9] = UInt8(((spannungsanzeige.intValue)>>8)%0xff);
      //print("spannungsanzeige high: \(spannungsanzeige.intValue)")
      
      var c0 = codeFeld.intValue + 1
      //codeFeld.intValue = c0
      let c1 = data0.intValue + 1
      data0.intValue = c1
      
      var senderfolg = teensy.send_USB()

   }
    else
    {
      timer.invalidate()
   }

   }
   
   
   func update_extspannung ( extspanung_new:Double)
   {
      extspannungFeld.doubleValue = extspanung_new
      extspannungStepper.doubleValue = extspanung_new
   }
   
   
   override var representedObject: AnyObject? {
      didSet {
         // Update the view, if already loaded.
      }
   }
   
   @IBAction func ExitNow(sender: AnyObject) {
      NSApplication.sharedApplication().terminate(self)
   }
   
}

