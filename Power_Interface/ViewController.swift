//
//  ViewController.swift
//  Power_Interface
//
//  Created by Ruedi Heimlicher on 02.11.2014.
//  Copyright (c) 2014 Ruedi Heimlicher. All rights reserved.
//

import Cocoa
import AVFoundation
import Darwin

let TEENSYPRESENT   =   7

// USB Eingang
// Temperatur
let DSLO = 8
let DSHI = 9

// ADC
let  ADCLO      =      10
let  ADCHI      =      11

// USB Ausgang
let SERVOALO = 10
let SERVOAHI = 11

let MMCLO = 16
let MMCHI = 17


// Task
let WRITE_MMC_TEST  =   0xF1



let TAKT_LO_BYTE = 14
let TAKT_HI_BYTE = 15

let DATACOUNT_LO    =   12 // Messung, laufende Nummer
let DATACOUNT_HI    =   13


let DATA_START_BYTE   = 16    // erstes byte fuer Data

let LOGGER_START = 0xA0
let LOGGER_CONT = 0xA1

let LOGGER_STOP = 0xAF

let LOGGER_SETTING    =  0xB0 // Setzen der Settings fuer die Messungen

let USB_STOP    = 0xAA

class ViewController: NSViewController, NSWindowDelegate
{
//   let meineNotification = Notification.Name(rawValue:"newDataNotification")
   
   
   // var  myUSBController:USBController
   // var usbzugang:
   var usbstatus: __uint8_t = 0
   
   var usb_read_cont = false; // kontinuierlich lesen
   var usb_write_cont = false; // kontinuierlich schreiben
   
   // Logger lesen
   var startblock:UInt16 = 1 // Byte 1,2: block 1 ist formatierung
   var blockcount:UInt16 = 0 // Byte 3, 4: counter beim Lesen von mehreren Bloecken
   var packetcount :UInt8 = 0 // byte 5: counter fuer pakete beim Lesen eines Blocks 10 * 48 + 32
   
   var loggerDataArray:[[UInt8]] = [[]]
   
   
   var LoggerData = Data()
   
   var teensy = usb_teensy()
   
   
   var teensycode:UInt8 = 0
  
   var spistatus:UInt8 = 0;
   
   @IBOutlet weak var manufactorer: NSTextField!
   @IBOutlet weak var Counter: NSTextField!
   
   @IBOutlet weak var Start: NSButton!
   
   @IBOutlet weak var inputDataFeldFeld: NSTextField!
   
   @IBOutlet weak var USB_OK: NSTextField!
   
   @IBOutlet weak var start_read_USB_Knopf: NSButton!
   @IBOutlet weak var stop_read_USB_Knopf: NSButton!
   @IBOutlet weak var cont_read_check: NSButton!

   @IBOutlet weak var start_write_USB_Knopf: NSButton!
   @IBOutlet weak var stop_write_USB_Knopf: NSButton!
   @IBOutlet weak var cont_write_check: NSButton!

   
   @IBOutlet weak var codeFeld: NSTextField!
   
   @IBOutlet weak var data0: NSTextField!
   
   @IBOutlet weak var data1: NSTextField!
   
   @IBOutlet  var inputDataFeld: NSTextView!

   
    @IBOutlet  var downloadDataFeld: NSTextView!
   
   
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
   
   
   @IBOutlet weak var extspannungStepper: NSStepper!
   
   
   // Datum
   @IBOutlet weak var sec_Feld: NSTextField!
   @IBOutlet weak var min_Feld: NSTextField!
   @IBOutlet weak var std_Feld: NSTextField!
   @IBOutlet weak var wt_Feld: NSTextField!
   @IBOutlet weak var mon_Feld: NSTextField!
   @IBOutlet weak var jahr_Feld: NSTextField!
   @IBOutlet weak var datum_Feld: NSTextField!
   @IBOutlet weak var zeit_Feld: NSTextField!
   @IBOutlet weak var tagsec_Feld: NSTextField!
   @IBOutlet weak var tagmin_Feld: NSTextField!

   
   @IBOutlet weak var DSLO_Feld: NSTextField!
   @IBOutlet weak var DSHI_Feld: NSTextField!
   @IBOutlet weak var DSTempFeld: NSTextField!

   // ADC
   @IBOutlet weak var ADCLO_Feld: NSTextField!
   @IBOutlet weak var ADCHI_Feld: NSTextField!
   @IBOutlet weak var ADCFeld: NSTextField!

   @IBOutlet weak var ServoASlider: NSSlider!

   // Logging
   @IBOutlet weak var Start_Logger: NSButton!
   @IBOutlet weak var Stop_Logger: NSButton!
   
   
   // Einstellungen
   @IBOutlet weak var IntervallPop: NSComboBox!
   @IBOutlet weak  var TaskListe: NSTableView!
   @IBOutlet weak var Set_Settings: NSButton!
   
   // USB-code
   @IBOutlet weak var bit0_check: NSButton!
   @IBOutlet weak var bit1_check: NSButton!
   @IBOutlet weak var bit2_check: NSButton!
   @IBOutlet weak var bit3_check: NSButton!
   @IBOutlet weak var bit4_check: NSButton!
   @IBOutlet weak var bit5_check: NSButton!
   @IBOutlet weak var bit6_check: NSButton!
   @IBOutlet weak var bit7_check: NSButton!
   
   // mmc
    @IBOutlet weak var mmcLOFeld: NSTextField!
    @IBOutlet weak var mmcHIFeld: NSTextField!
    @IBOutlet weak var mmcDataFeld: NSTextField!
   
   
   var taskArray: NSMutableArray! = NSMutableArray()
   
   var swiftArray = [[String:AnyObject]]()
   
   //MARK: - Konfig Messung
   
   @IBAction func reportSetSettings(_ sender: NSButton)
   {
      print("reportSetSettings")
      print("\(swiftArray)")
      teensy.write_byteArray[0] = UInt8(LOGGER_SETTING)
      
      //Intervall lesen
      let selectedItem = IntervallPop.indexOfSelectedItem
      let intervallwert = IntervallPop .intValue
       // Taktintervall in array einsetzen
      teensy.write_byteArray[TAKT_LO_BYTE] = UInt8(intervallwert & 0x00FF)
      teensy.write_byteArray[TAKT_HI_BYTE] = UInt8((intervallwert & 0xFF00)>>8)
      //    print("reportTaskIntervall teensy.write_byteArray[TAKT_LO_BYTE]: \(teensy.write_byteArray[TAKT_LO_BYTE])")

      
      var senderfolg = teensy.start_write_USB()
      

      var toppings =
         ["Pepperoni":0.25,
          "Sausage":0.26,
          "Onions":0.02,
          "Green Peppers":0.03,
          "Cheese":0.01
      ]
      
      //let items : Array<String> = (swiftArray as AnyObject).valueForKeyPath("name") as! Array<String>

      //let items : Array<String> = (swiftArray as AnyObject).value(forKeyPath:"task") as! Array<String>
   
   //print("item: \(items)")
      
   }
 
   
   @IBAction func reportTaskIntervall(_ sender: NSComboBox)
   {
      print("reportTaskIntervall index: \(sender.indexOfSelectedItem)")
      if (sender.indexOfSelectedItem >= 0)
      {
         let wahl = sender.objectValueOfSelectedItem! as! String
        let index = sender.indexOfSelectedItem
        // print("reportTaskIntervall wahl: \(wahl) index: \(index)")
         // http://stackoverflow.com/questions/24115141/swift-converting-string-to-int
         let integerwahl:UInt16? = UInt16(wahl)
         print("reportTaskIntervall integerwahl: \(integerwahl!)")
        
         if let integerwahl = UInt16(wahl)
         {
            print("By optional binding :", integerwahl) // 20
         }
        
         //et num:Int? = Int(firstTextField.text!);
      // Taktintervall in array einsetzen
      teensy.write_byteArray[TAKT_LO_BYTE] = UInt8(integerwahl! & 0x00FF)
      teensy.write_byteArray[TAKT_HI_BYTE] = UInt8((integerwahl! & 0xFF00)>>8)
     //    print("reportTaskIntervall teensy.write_byteArray[TAKT_LO_BYTE]: \(teensy.write_byteArray[TAKT_LO_BYTE])")
 
      }
   }
   
   @IBAction func reportTaskListe(_ sender: NSTableView)
   {
      //print("reportTaskListe index: \(sender.selectedColumn)")

   }
   
   @IBAction func reportTaskCheck(_ sender: NSButton)
   {
      //print("reportTaskCheck state: \(sender.state)")
      //let zeile = TaskListe.selectedRow
      //var zelle = swiftArray[TaskListe.selectedRow] //as! [String:AnyObject]
      
     // let check = zelle["task"] as! Int
     // if (check == 0)
     
      if (swiftArray[TaskListe.selectedRow]["task"] as! Int == 1)
      {
         swiftArray[TaskListe.selectedRow]["task"] = 0  as AnyObject?
      }
      else
      {
         //zelle["task"] = 0 as AnyObject?
         swiftArray[TaskListe.selectedRow]["task"] = 1  as AnyObject?
      }
   }
   

   
   @IBAction func report_cont_write(_ sender: AnyObject)
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
   
   
   @IBAction func report_cont_read(_ sender: AnyObject)
   {
      if (sender.state == 0)
      {
         usb_read_cont = false
      }
      else
      {
         usb_read_cont = true
      }
      //println("report_cont_read usb_read_cont: \(usb_read_cont)")
   }
   
  
   
   @IBAction func controlDidChange(_ sender: AnyObject)
   {
      print("controlDidChange: \(sender.doubleValue)")
      self.update_extspannung(sender.doubleValue)
      self.setSpannung()
   }
   
    @IBAction func reportBit0(_ sender: AnyObject)
    {
      print("reportBit0 tag: \(sender.tag)")
      let bit:UInt8 = UInt8(sender.tag)
      if (sender.state == 1)
      {
         usbstatus |= (1<<bit)
      }
      else
      {
         usbstatus &= ~(1<<bit)
      }
      codeFeld.intValue = Int32(usbstatus)
   }
   
   @IBAction func reportWriteCodeBit(_ sender: AnyObject)
   {
      print("reportBit1 tag: \(sender.tag)")
      let bit:UInt8 = UInt8(sender.tag)
      if (sender.state == 1)
      {
         usbstatus |= (1<<bit)
      }
      else
      {
         usbstatus &= ~(1<<bit)
      }
      codeFeld.intValue = Int32(usbstatus)
   }

   @IBAction func sendServoA(_ sender: AnyObject)
   {
      
      var formatter = NumberFormatter()
      var tempspannung:Double  = extspannungFeld.doubleValue * 100
      if (tempspannung > 3000)
      {
         tempspannung = 3000
         
         
      }
      
      let tempPos = ServoASlider.intValue
      
      //      extspannungFeld.doubleValue = ((tempspannung/100)+1)%12
      //var tempintspannung = UInt16(tempspannung)
      //NSString(format:"%2X", a2)
      //spL.stringValue = NSString(format:"%02X", (tempintspannung & 0x00FF)) as String
      //spH.stringValue = NSString(format:"%02X", ((tempintspannung & 0xFF00)>>8)) as String
      print("tempPos: \(tempPos)");// L: \(spL.stringValue)\ttempintspannung H: \(spH.stringValue) ")
      //teensy.write_byteArray[0] = 0x01
      print("write_byteArray 0: \(teensy.write_byteArray[0])")
      teensy.write_byteArray[10] = UInt8(tempPos & (0x00FF))
      teensy.write_byteArray[11] = UInt8((tempPos & (0xFF00))>>8)
      print("write_byteArray 10: \(teensy.write_byteArray[10])\t 11: \(teensy.write_byteArray[11])")
      var senderfolg = teensy.start_write_USB()
      teensy.write_byteArray[0] = 0x00 // bit 0 zuruecksetzen
      //senderfolg = teensy.report_start_write_USB()
   }

   
   
   @IBAction func sendSpannung(_ sender: AnyObject)
   {
 
      var formatter = NumberFormatter()
      var tempspannung:Double  = extspannungFeld.doubleValue * 100
      if (tempspannung > 3000)
      {
         tempspannung = 3000
         
        
      }
//      extspannungFeld.doubleValue = ((tempspannung/100)+1)%12
      let tempintspannung = UInt16(tempspannung)
      //NSString(format:"%2X", a2)
      spL.stringValue = NSString(format:"%02X", (tempintspannung & 0x00FF)) as String
      spH.stringValue = NSString(format:"%02X", ((tempintspannung & 0xFF00)>>8)) as String
      print("tempintspannung L: \(spL.stringValue)\ttempintspannung H: \(spH.stringValue) ")
      teensy.write_byteArray[0] = 0x01
      print("write_byteArray 0: \(teensy.write_byteArray[0])")
      teensy.write_byteArray[1] = UInt8(tempintspannung & (0x00FF))
      teensy.write_byteArray[2] = UInt8((tempintspannung & (0xFF00))>>8)
      
      var senderfolg = teensy.start_write_USB()
      teensy.write_byteArray[0] = 0x00 // bit 0 zuruecksetzen
      //senderfolg = teensy.report_start_write_USB()
   }
 
   func setSpannung()
   {
      var beepSound = URL(fileURLWithPath: Bundle.main.path(forResource: "beep", ofType: "aif")!)
      
      
      var formatter = NumberFormatter()
      var tempspannung:Double  = extspannungFeld.doubleValue * 100
      if (tempspannung > 3000)
      {
         tempspannung = 3000
         
         
      }
      //      extspannungFeld.doubleValue = ((tempspannung/100)+1)%12
      let tempintspannung = UInt16(tempspannung)
      //NSString(format:"%2X", a2)
      spL.stringValue = NSString(format:"%02X", (tempintspannung & 0x00FF)) as String
      spH.stringValue = NSString(format:"%02X", ((tempintspannung & 0xFF00)>>8)) as String
      print("tempintspannung L: \(spL.stringValue)\ttempintspannung H: \(spH.stringValue) ")
      teensy.write_byteArray[0] = 0x01
      print("write_byteArray 0: \(teensy.write_byteArray[0])")
      teensy.write_byteArray[1] = UInt8(tempintspannung & (0x00FF))
      teensy.write_byteArray[2] = UInt8((tempintspannung & (0xFF00))>>8)
      
      var senderfolg = teensy.start_write_USB()
      teensy.write_byteArray[0] = 0x00 // bit 0 zuruecksetzen
      //senderfolg = teensy.report_start_write_USB()
   }

   
   
   @IBAction func sendStrom(_ sender: AnyObject)
   {
      var formatter = NumberFormatter()
      var tempstrom:Double  = extstrom.doubleValue * 100
      if (tempstrom > 3000)
      {
         tempstrom = 3000
         
      }
      let ired = NSString(format:"%2.2f", tempstrom/100)
      extstrom.stringValue = ired as String
      let tempintstrom = UInt16(tempstrom)
      //NSString(format:"%2X", a2)
      spL.stringValue = NSString(format:"%02X", (tempintstrom & 0x00FF)) as String
      spH.stringValue = NSString(format:"%02X", ((tempintstrom & 0xFF00)>>8)) as String
      print("tempintstrom L: \(spL.stringValue)\ttempintstrom H: \(spH.stringValue) ")
      teensy.write_byteArray[0] = 0x02
      print("write_byteArray 0: \(teensy.write_byteArray[0])")
      teensy.write_byteArray[1] = UInt8(tempintstrom & (0x00FF))
      teensy.write_byteArray[2] = UInt8((tempintstrom & (0xFF00))>>8)
      
      var senderfolg = teensy.start_write_USB()
      teensy.write_byteArray[0] = 0x00
   }
   
   
   open func writeData(name:String, data:String)
   {
      /*
       // http://www.techotopia.com/index.php/Working_with_Directories_in_Swift_on_iOS_8
       do {
       let filelist = try filemgr.contentsOfDirectory(atPath: "/")
       
       for filename in filelist {
       print(filename)
       }
       } catch let error {
       print("Error: \(error.localizedDescription)")
       }
 */
      print ("\nwriteData data: \(data)")
      
      //http://stackoverflow.com/questions/24097826/read-and-write-data-from-text-file
      // http://www.techotopia.com/index.php/Working_with_Directories_in_Swift_on_iOS_8
      
      do
      {
         let documentDirectoryURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
         var datapfad = documentDirectoryURL.appendingPathComponent("LoggerdataDir")
         
         do
         {
            try FileManager.default.createDirectory(atPath: datapfad.path, withIntermediateDirectories: true, attributes: nil)
         }
         catch let error as NSError
         {
            print(error.localizedDescription);
         }
         
         
         print ("datapfad: \(datapfad)")
         
         datapfad = datapfad.appendingPathComponent(name)
         
            //writing
            do
            {
               try data.write(to: datapfad, atomically: false, encoding: String.Encoding.utf8)
            }
         catch let error as NSError
         {
            print(error.localizedDescription);
         }
      }
      catch
      {
         print("catch write")
      }
         
      return
      if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
      {
         
         let path = dir.appendingPathComponent(data)
         
         //writing
         do
         {
            try data.write(to: path, atomically: false, encoding: String.Encoding.utf8)
         }
         catch {/* error handling here */}
         
         //reading
         do {
            let text2 = try String(contentsOf: path, encoding: String.Encoding.utf8)
            print("text2: \(text2)")
            inputDataFeld.string = text2
         }
         catch {/* error handling here */}
         
      }
   } // writeData
   
   
   func tagsekunde()-> Int
   {
      let date = Date()
      let calendar = Calendar.current
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "gsw-CH")

      let stunde = calendar.component(.hour, from: date)
      let minute = calendar.component(.minute, from: date)
      let sekunde = calendar.component(.second, from: date)
      return 3600 * stunde + 60 * minute + sekunde
   }
   
   func datumstring()->String
   {
      let date = Date()
      let calendar = Calendar.current
      let jahr = calendar.component(.year, from: date)
      let tagdesmonats = calendar.component(.day, from: date)
      let monatdesjahres = calendar.component(.month, from: date)
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "gsw-CH")

      formatter.dateFormat = "dd.MM.yyyy"
      let datumString = formatter.string(from: date)
      print("datumString: \(datumString)*")
      return datumString
   }
   
   func zeitstring()->String
   {
      let date = Date()
      let calendar = Calendar.current
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "gsw-CH")
      
      let stunde = calendar.component(.hour, from: date)
      let minute = calendar.component(.minute, from: date)
      let sekunde = calendar.component(.second, from: date)
      formatter.dateFormat = "hh:mm:ss"
      let zeitString = formatter.string(from: date)
      return zeitString
   }
   
  //MARK: - viewDidLoad
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      NotificationCenter.default.addObserver(self, selector: #selector(ViewController.USBfertigAktion(_:)), name: NSNotification.Name(rawValue: "NSWindowWillCloseNotification"), object: nil)
      
      // http://dev.iachieved.it/iachievedit/notifications-and-userinfo-with-swift-3-0/
      
      let nc = NotificationCenter.default //
      
      nc.addObserver(forName:Notification.Name(rawValue:"newdata"),// Name im Aufruf in usb.swift
                     object:nil, queue:nil,
                     using:newDataNotification)
      var deg=0.0;
      while deg<50
      {
         let winkel = M_PI * 2.0 * deg / 360.0
         let sinus1 = sin(M_PI * 2.0 * deg / 240.0)
         let sinus2 = sin((M_PI * 2.0 * deg / 180.0 ) * 13)
         let sinus3 = sin((M_PI * 2.0 * deg / 120.0 ) * 5)

         deg = deg + 2
         let sinus = sinus1 + sinus2 * 0.5 + sinus3 * 0.7 + 1.0
//         print("\(winkel)\t\(sinus1)\t\(sinus2)\t\(sinus3)\t\(sinus)")
      }
      
      let calendardatum = Calendar.current
      let date = Date()
      
      let components = calendardatum.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date as Date)
      let year =  components.year!-2000
      let month = components.month!
      let day = components.day!
      let hour = components.hour!
      let min = components.minute!
      let sec = components.second!
      let tagminute = hour * 60 + min
      tagmin_Feld.integerValue = tagminute
      
      //let tagsekunde = tagminute * 60 + sec
      
      
      
      tagsec_Feld.integerValue = tagsekunde()
      print(year)
      jahr_Feld.integerValue = year
      print(month)
      mon_Feld.integerValue = month
      print(day)
      wt_Feld.integerValue = day
      print(hour)
      std_Feld.integerValue = hour
      print(min)
      min_Feld.integerValue = min
      
    //  let components = date.components
       print("date: \(date) ")
      
      let myLocale = Locale(identifier: "gsw-CH")
      
      //: ### Setting an application-wide `TimeZone`
      //: Notice how we use if-let in case the abbreviation is wrong. It will fallback to the default timezone in that case.
      if let myTimezone = TimeZone(abbreviation: "GMT")
      {
         print("\(myTimezone.identifier)")
      }
      
      let formatter = DateFormatter()
      formatter.locale = myLocale
      
      formatter.dateStyle = .medium
      formatter.timeStyle = .medium
      formatter.dateFormat = "dd.MM.yyyy"
      var dateStr = formatter.string(from: date)
      print("dateStr: \(dateStr)*")
      formatter.dateFormat = "hh:mm.ss"
      var timeStr = formatter.string(from: date)
      print("timeStr: \(timeStr)*")


    //  let formatter = DateFormatter()
      formatter.dateFormat = "dd.MM.yyyy : hh:mm::ss"
      //formatter.dateFormat = "yyMMdd_hhmm"
      
  //    let datum = formatter.string(from: date)
      let datum = "\(day).\(month).\(year)"
      
      datum_Feld.stringValue = datumstring()
      print("Datum: \(datum)\tdateStr: \(dateStr)")
      zeit_Feld.stringValue = zeitstring()
      
      
      
      writeData(name: "abc.txt",data:"Hallo")
      //textfile end
     // let xy = Hello()
     // USB_OK.backgroundColor = NSColor.yellowColor()
      USB_OK.textColor = NSColor.yellow
       USB_OK.stringValue = "?";
      // Do any additional setup after loading the view.
      
      //spannungsanzeige.numberOfTickMarks = 16
      extspannungFeld.doubleValue = 5.0
      extspannungStepper.doubleValue = 5.0
      //inputDataFeld.string = "inputDataFeld-data"
   
      teensy.write_byteArray[0] = 0xFE
      
      //MARK: -   TaskListe
      TaskListe.delegate = self
      TaskListe.dataSource = self
      
      var tempDic = [String:AnyObject]()
      
      tempDic["task"] = 1  as AnyObject?
      tempDic["description"] = "Temperatur messen"  as AnyObject?
      tempDic["util"] = "T < 100°C"  as AnyObject?
     
      swiftArray.append(tempDic)

      tempDic["task"] = 0 as AnyObject?
      tempDic["description"] = "Spannung messen"  as AnyObject?
      tempDic["util"] = "U <= 5V"  as AnyObject?
      
      swiftArray.append(tempDic)
      
      tempDic["task"] = 0 as AnyObject?
      tempDic["description"] = "Strom messen"  as AnyObject?
      tempDic["util"] = "I <= 10A"  as AnyObject?
      
      swiftArray.append(tempDic)

      
      //print("swiftArray: \(swiftArray)")
      
      // Zeile aendern:
      /*
      let zeile = 1
      swiftArray[zeile]["util"] = "< 100A"  as AnyObject?
      swiftArray[zeile]["description"] = "Strom messen"  as AnyObject?
      
      swiftArray[zeile]["task"] = 33  as AnyObject?
      print("swiftArray2: \(swiftArray)")
       */

      
      IntervallPop.usesDataSource = false
   
   
   
   }
   
   //MARK: -   newDataNotification
   // http://dev.iachieved.it/iachievedit/notifications-and-userinfo-with-swift-3-0/

   func newDataNotification(notification:Notification) -> Void
   {
//      print("ViewController newDataNotification info: \(notification.name)")
      //print("ViewController newDataNotification  userinfo data: \(notification.userInfo?["data"])");
      
   
   }
   
   
   func USBfertigAktion(_ sender: AnyObject)-> Bool
   {
      NSLog("USBfertigAktion will schliessen")
      
      stop_read_USB(self)
      stop_write_USB(self)
      
      teensycode &= ~(1<<7)
      teensy.write_byteArray[15] = teensycode
      teensy.write_byteArray[0] = UInt8(USB_STOP)
//    teensy.write_byteArray[1] = UInt8(data0.intValue)
      
      let senderfolg = teensy.start_write_USB()
      if (senderfolg > 0)
      {
          NSApplication.shared().terminate(self)
         return true
      }
      NSApplication.shared().terminate(self)
      return false
   }
   
   
   @IBAction func startU_Funktion(_ sender: NSButton)
   {
      let timerDic:NSMutableDictionary = ["delta": 1.0]
      var timer : Timer? = nil
      timer = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(ViewController.cont_U_Funktion(_:)), userInfo: timerDic, repeats: true)

   }

   func cont_U_Funktion(_ timer: Timer)
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
         var senderfolg = teensy.start_write_USB()
         teensy.write_byteArray[0] = 0x00 // bit 0 zuruecksetzen

      }
      
   }
   
   
   func tester(_ timer: Timer)
   {
      let theStringToPrint = timer.userInfo as! String
      print(theStringToPrint)
   }
   
   
   @IBAction func Teensy_setState(_ sender: NSButton)
   {
      if (sender.state > 0)
      {
         sender.title = "Teensy ON"
         teensycode |= (1<<7)
         teensy.write_byteArray[15] = teensycode
        // teensy.write_byteArray[0] |= UInt8(Teensy_Status.intValue)
        // teensy.write_byteArray[1] = UInt8(data0.intValue)
         
         var senderfolg = teensy.start_write_USB()

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
         var senderfolg = teensy.start_write_USB()
         
      }
   }
   
   @IBAction func start_read_USB(_ sender: AnyObject)
   {
      print("start_read_USB")
      //myUSBController.startRead(1)
      
      usb_read_cont = (cont_read_check.state == 1) // cont_Read wird bei aktiviertem check eingeschaltet

     let readerr = teensy.start_read_USB(usb_read_cont)
      if (readerr == 0)
      {
         print("Fehler in start_read_usb")
      }
      
      let DSLOW:Int32 = Int32(teensy.read_byteArray[DSLO])
      let DSHIGH:Int32 = Int32(teensy.read_byteArray[DSHI])
      
      if (DSLOW > 0)
      {
         let temperatur = DSLOW | (DSHIGH<<8)
         
         print("DSLOW: \(DSLOW)\tSDHIGH: \(DSHIGH)\n");
         DSLO_Feld.intValue = DSLOW
         DSHI_Feld.intValue = DSHIGH
         let  temperaturfloat:Float = Float(temperatur)/10.0
         _ = NumberFormatter()
         
         let t:NSString = NSString(format:"%.01f", temperaturfloat) as String as String as NSString
         //print("temperaturfloat: \(temperaturfloat) String: \(t)");
         DSTempFeld.stringValue = NSString(format:"%.01f°C", temperaturfloat) as String
         //DSTempFeld.floatValue = temperaturfloat
      }

      
      let ADC0LO:Int32 =  Int32(teensy.read_byteArray[ADCLO])
      let ADC0HI:Int32 =  Int32(teensy.read_byteArray[ADCHI])
      ADCLO_Feld.intValue = ADC0LO
      ADCHI_Feld.intValue = ADC0HI
      
      let adc0 = ADC0LO | (ADC0HI<<8)
      let  adcfloat:Float = Float(adc0)/0xFFFF*5.0
      _ = NumberFormatter()

      //print("adcfloat: \(adcfloat) String: \(adcfloat)");
      ADCFeld.stringValue = NSString(format:"%.02f", adcfloat) as String
      
      //print ("adc0: \(adc0)");
      
      //teensy.start_teensy_Timer()
      
      //     var somethingToPass = "It worked"
      
      //      let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("tester:"), userInfo: somethingToPass, repeats: true)
      
      if (usb_read_cont == true)
      {
      var timer : Timer? = nil
      
      // Auslesen der Ergebnisse in teensy
      timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.cont_read_USB(_:)), userInfo: nil, repeats: true)
      }
   }
   
   func cont_read_USB(_ timer: Timer)
   {
      if (usb_read_cont)
      {
         //NSBeep()
         if (teensy.new_Data).boolValue
         {
            tagsec_Feld.integerValue = tagsekunde()
            teensy.new_Data = false
            // NSBeep()
            let code:Int = Int(teensy.last_read_byteArray[0])
            
            //print("\ncont_read_USB code: \(code)")
            switch (code)
            {
            case LOGGER_SETTING:
               print("LOGGER_SETTINGS:")
               print("Nr: \(teensy.last_read_byteArray[DATACOUNT_LO]) \(teensy.last_read_byteArray[DATACOUNT_HI]) ")
               
               
            case LOGGER_START:
               
               
                  let startblockLO: UInt8 = teensy.last_read_byteArray[1]
                  let startblockHI: UInt8 = teensy.last_read_byteArray[2]
                  
                  
                  let packetcount: UInt8 = teensy.last_read_byteArray[3]
               print("cont_read_USB LOGGER_START: \(code)\t packetcount: \(packetcount)")

//MARK: LOGGER_CONT
            case LOGGER_CONT:
               
               //print("cont_read_USB logger cont: \(code)")
               let packetcount: UInt8 = teensy.last_read_byteArray[3]
               print("cont_read_USB LOGGER_CONT: \(code)\t packetcount: \(packetcount)")
               
               // gelesene Daten
               var ind = 0
 
               print("CONT read_byteArray:")
               
               //var loggerstring:String
               if (teensy.last_read_byteArray.count > 1)
               {
                  // http://stackoverflow.com/questions/25581324/swift-how-can-string-join-work-custom-types
                  let temparray = teensy.last_read_byteArray[8...(BUFFER_SIZE-9)]
                  
                  let tempstring = temparray.map{String($0)}.joined(separator: "\t")
                  
                  //var tempstring = teensy.last_read_byteArray.map{String($0)}.joined(separator: ",")
                  
                  
                  // http://stackoverflow.com/questions/36076014/uint8-array-to-strings-in-swift
                  //    let stringArray = teensy.last_read_byteArray.map( { "\($0)" })
                  //     print(stringArray)
                  // let tempstring = String(bytes: teensy.last_read_byteArray, encoding: String.Encoding.utf8)
                  
                  inputDataFeld.string = inputDataFeld.string! + "\n" + tempstring
               }
               for  ind in 8...BUFFER_SIZE - 1 - 8
                  //while i < 64
               {
                //  let temp = teensy.last_read_byteArray[ind]
                  
                 // loggerstring = loggerstring + (teensy.last_read_byteArray[ind] as String)
                  print("\(teensy.last_read_byteArray[ind])", terminator: "\t")
                  //ind = ind + 1
               }

              // print("\(teensy.last_read_byteArray)")
               loggerDataArray.append(teensy.last_read_byteArray);

               if (packetcount < 10)
               {
                  
               // Anfrage fuer naechstes Paket schicken
               //packetcount =   packetcount + 1
                  cont_log_USB(paketcnt: (packetcount))
               }
               else
               {
                  teensy.read_OK = false
                  teensy.write_byteArray[0] = UInt8(LOGGER_STOP)
                  usb_read_cont = false
                  cont_read_check.state = 0;
                  
                  writeData(name: "loggerdump.txt",data:inputDataFeld.string!)
                  
                  print("\n")
                  var senderfolg = teensy.start_write_USB()

                  
                  print("\nloggerDataArray:")
                  print ("\(loggerDataArray)")
               }
               
            case LOGGER_STOP:
               packetcount = 0
               print("\nLOGGER_STOP")
               
               
//cont_log_USB
            case WRITE_MMC_TEST:
               print("code ist WRITE_MMC_TEST")
               
            case USB_STOP:
               print("code ist USB_STOP")
               
            
            default: break
               //print("code ist 0")
            } // switch code
            
            var data = NSData(bytes: teensy.last_read_byteArray, length: 32)
            //print("data: \(data)")
            
            // let inputDataFeldstring = teensy.last_read_byteArray as NSArray
            
            let b1: Int32 = Int32(teensy.last_read_byteArray[1])
            let b2: Int32 = Int32(teensy.last_read_byteArray[2])
            
            //print("b1: \(b1)\tb2: \(b2)\n");
            
            H_Feld.intValue = b2
            H_Feld.stringValue = NSString(format:"%2X", b1) as String
            
            // H_Feld.stringValue = NSString(format:"%d", a2)
            
            L_Feld.intValue = b1
            L_Feld.stringValue = NSString(format:"%2X", b1) as String
            // L_Feld.stringValue = NSString(format:"%d", a1)
            
            let rotA:Int32 = (b1 | (b2<<8))
            
            //inputDataFeldFeld.stringValue = NSString(format:"%2X", rotA)
            inputDataFeldFeld.intValue = Int32(rotA)
            
            spannungsanzeige.intValue = Int32(rotA )
            
            
            
            let DSLOW:Int8 = Int8(teensy.last_read_byteArray[DSLO])
            let DSHIGH:Int8 = Int8(teensy.last_read_byteArray[DSHI])
            
            if (DSLOW > 0)
            {
               let temperatur = DSLOW | (DSHIGH<<8)
            
               print("DSLOW: \(DSLOW)\tSDHIGH: \(DSHIGH) temperatur: \(temperatur)\n");
               
               DSLO_Feld.intValue = Int32(DSLOW)
               DSHI_Feld.intValue = Int32(DSHIGH)
               
               let  temperaturfloat:Float = Float(temperatur)/10.0
               _ = NumberFormatter()
            
               let t:NSString = NSString(format:"%.01f", temperaturfloat) as String as String as NSString
               print("temperaturfloat: \(temperaturfloat) String: \(t)");
               DSTempFeld.stringValue = NSString(format:"%.01f°C", temperaturfloat) as String
            //DSTempFeld.floatValue = temperaturfloat
            }
            
            
            let ADC0LO:Int32 =  Int32(teensy.read_byteArray[ADCLO])
            let ADC0HI:Int32 =  Int32(teensy.read_byteArray[ADCHI])
            
            let adc0 = ADC0LO | (ADC0HI<<8)
            
            print ("ADC0LO: \(ADC0LO) ADC0HI: \(ADC0HI)  adc0: \(adc0)");

           // print ("adc0: \(adc0)");
            ADCLO_Feld.intValue = ADC0LO
            ADCHI_Feld.intValue = ADC0HI
            
            let  adcfloat:Float = Float(adc0) * 249 / 1024   // Kalibrierung teensy2: VREF ist 2.49 anstatt 2.56
            print ("adcfloat: \(adcfloat)");
            
            let NR_LO = Int32(teensy.read_byteArray[DATACOUNT_LO])
            let NR_HI = Int32(teensy.read_byteArray[DATACOUNT_HI])
            
            
            let messungnummer = NR_LO | (NR_HI<<8)
            let nrstring = String(messungnummer )
            _ = NumberFormatter()
            
            //print("adcfloat: \(adcfloat) String: \(adcfloat)");
            ADCFeld.stringValue = NSString(format:"%.01f", adcfloat) as String
            loggerDataArray.append([UInt8(ADC0LO)]);
            
            var tempinputDataFeldstring = String(tagsekunde()) + "\t" +  ADCFeld.stringValue
            
            // Zeile in inputDataFeld laden
            inputDataFeld.string = inputDataFeld.string! + String(messungnummer) + "\t" +  tempinputDataFeldstring + "\n" 


            let ADC1LO:Int32 =  Int32(teensy.read_byteArray[ADCLO+2])
            let ADC1HI:Int32 =  Int32(teensy.read_byteArray[ADCHI+2])
            let adc1 = ADC1LO | (ADC1HI<<8)

            
            
            print ("ADC1LO: \(ADC1LO) ADC1HI: \(ADC1HI)  adc1: \(adc1)");
      
            
            
            // mmc
            let mmcLO:Int32 = Int32(teensy.last_read_byteArray[MMCLO])
            let mmcHI:Int32 = Int32(teensy.last_read_byteArray[MMCHI])
            let mmcData  = mmcLO | (mmcHI >> 8)
            mmcLOFeld.intValue = mmcLO
            mmcHIFeld.intValue = mmcHI
            mmcDataFeld.intValue = mmcData
            teensy.new_Data = false
            
            
         }
         
      }
      else
      {
         timer.invalidate()
      }
   }

   
   
   @IBAction func check_USB(_ sender: NSButton)
   {
      let erfolg = UInt8(teensy.USBOpen())
      usbstatus = erfolg
      print("USBOpen erfolg: \(erfolg) usbstatus: \(usbstatus)")
      
      if (rawhid_status()==1)
      {
        // NSBeep()
         print("status 1")
         USB_OK.textColor = NSColor.green
         USB_OK.stringValue = "OK";
         manufactorer.stringValue = "Manufactorer: " + teensy.manufactorer()!
         
         Teensy_Status.isEnabled = true;
         start_read_USB_Knopf.isEnabled = true;
         stop_read_USB_Knopf.isEnabled = true;
         start_write_USB_Knopf.isEnabled = true;
         stop_write_USB_Knopf.isEnabled = true;
      }
      else
         
      {
         print("status 0")
         USB_OK.textColor = NSColor.red
         USB_OK.stringValue = "X";
         Teensy_Status.isEnabled = false;
         start_read_USB_Knopf.isEnabled = false;
         stop_read_USB_Knopf.isEnabled = false;
         start_write_USB_Knopf.isEnabled = false;
         stop_write_USB_Knopf.isEnabled = false;

      }
      print("antwort: \(teensy.status())")
   }
   
   @IBAction func stop_read_USB(_ sender: AnyObject)
   {
      teensy.read_OK = false
      usb_read_cont = false
      cont_read_check.state = 0;
      
   }
   
   
   @IBAction func stop_write_USB(_ sender: AnyObject)
   {
      usb_write_cont = false
      cont_write_check.state = 0;
   }
   
   
//MARK: -   Logger
   @IBAction func report_start_download_logger_USB(_ sender: AnyObject)
   {
      
      print("report_start_download_logger_USB");
      zeit_Feld.stringValue = zeitstring()
     // tagmin_Feld.integerValue = tagminute
      tagsec_Feld.integerValue = tagsekunde()
      let erfolg = UInt8(teensy.USBOpen())
      if (erfolg == 0)
      {
         print("report_start_download_logger_USB: kein teensy da");
         return
      }

      teensy.write_byteArray[0] = UInt8(LOGGER_START)
      startblock=2;
      // index erster Block
      teensy.write_byteArray[1] = UInt8(startblock & 0x00FF)
      teensy.write_byteArray[2] = UInt8((startblock & 0xFF00)>>8)
      
      /*
      teensy.write_byteArray[3] =  UInt8(blockcount  & 0x00FF)
      teensy.write_byteArray[4] = UInt8((blockcount & 0xFF00)>>8)
       */
      teensy.write_byteArray[3] = packetcount // beginn bei Paket 0
      inputDataFeld.string = inputDataFeld.string! + "\nBlock: " + String(startblock)

      // cont write aktivieren
      cont_write_check.state = 1
      
      var senderfolg = teensy.start_write_USB()

   }
   
   //MARK: cont log
   func cont_log_USB(paketcnt: UInt8)
   {
      
      print("\ncont_log_USB packetcount: \(paketcnt)");
      teensy.write_byteArray[0] = UInt8(LOGGER_CONT) // code
      startblock = 1;
      // index erster Block
      teensy.write_byteArray[1] = UInt8(startblock & 0x00FF)
      teensy.write_byteArray[2] = UInt8((startblock & 0xFF00)>>8)
      /*
       teensy.write_byteArray[3] =  UInt8(blockcount  & 0x00FF)
       teensy.write_byteArray[4] = UInt8((blockcount & 0xFF00)>>8)
       */
      teensy.write_byteArray[3] = paketcnt // beginn bei Paket next
      
      var senderfolg = teensy.cont_write_USB()
      
   }

   

   @IBAction func report_stop_log_USB(_ sender: AnyObject)
   {
      print("report_start_write_USB");
      teensy.write_byteArray[0] = UInt8(LOGGER_STOP)

   }
   
   
   
   @IBAction func report_start_write_USB(_ sender: AnyObject)
   {
      //NSBeep()
      //print("report_start_write_USB code: \(codeFeld.intValue)")
      print("report_start_write_USB code string: \(codeFeld.stringValue)")
      let code:UInt8 = UInt8(codeFeld.stringValue, radix: 16)!
      
     // teensy.write_byteArray[0] = UInt8(codeFeld.intValue)
      teensy.write_byteArray[0] = code
      teensy.write_byteArray[1] = UInt8(data0.intValue)
      teensy.write_byteArray[2] = UInt8(data1.intValue)
      teensy.write_byteArray[3] = UInt8(data2.intValue)
      teensy.write_byteArray[4] = UInt8(data3.intValue)
//      print("new write_byteArray in report_start_write_USB: ", terminator: "\n")
      var i=0;
      
      //for  i in 0...63
      while i < 32
      {
         print("\(i)\t \(teensy.write_byteArray[i])\n", terminator: "")
         i = i+1
      }
      print("*")

      let dateA = Date()
      
      var senderfolg = teensy.start_write_USB()
      
      
      let dauer1 = Date() //
      let diff =  (dauer1.timeIntervalSince(dateA))*1000
      print("dauer report_start_write_USB: \(diff)")
      
      usb_write_cont = (cont_write_check.state == 1)
      
      //println("report_start_write_USB senderfolg: \(senderfolg)")
      
      
      /*
      var USB_Zugang = USBController()
      USB_Zugang.setKontrollIndex(5)
      
      Counter.intValue = USB_Zugang.kontrollIndex()
      
      // var  out  = 0
      
      //USB_Zugang.Alert("Hoppla")
      
      var x = getX()
      Counter.intValue = x
      
      var    out = rawhid_open(1, 0x16C0, 0x0480, 0xFFAB, 0x0200)
      
      println("report_start_write_USB out: \(out)")
      
      if (out <= 0)
      {
      usbstatus = 0
      inputDataFeldFeld.stringValue = "not OK"
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
      if (usb_write_cont)
      {
      var timer : Timer? = nil
      timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ViewController.cont_write_USB(_:)), userInfo: nil, repeats: true)
      }
   }
   
 func cont_write_USB(_ timer: Timer)
 {
    print("*** \tcont_write usb: \(usb_write_cont)")
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
      
      var senderfolg = teensy.cont_write_USB()

   }
    else
    {
      timer.invalidate()
   }

   }
   
   
   func update_extspannung ( _ extspanung_new:Double)
   {
      extspannungFeld.doubleValue = extspanung_new
      extspannungStepper.doubleValue = extspanung_new
   }
   
   
   
   @IBAction func ExitNow(_ sender: AnyObject)
   {
      NSLog("ExitNow");
      NSApplication.shared().terminate(self)
   }
   
}

// https://www.raywenderlich.com/143828/macos-nstableview-tutorial
//MARK: - tableView delegate
// NSTableViewDataSource
extension ViewController: NSTableViewDataSource
{
   
   func numberOfRows(in tableView: NSTableView) -> Int
   {
      return self.swiftArray.count
   }
}

extension ViewController: NSTableViewDelegate
{
   
   fileprivate enum CellIdentifiers
   {
      static let taskCell = "task"
      static let descCell = "description"
      static let utilCell = "util"
   }
   
   
   func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?
   {
      
      // var tempzeile = swiftArray[row]
      
      guard let item = swiftArray[row]["task"]
         else
      {
         return nil
      }
      
      if (tableColumn?.identifier == "task")
      {
         //let temp = self.taskArray.object(at: row) as! NSDictionary
         //let swifttemp = swiftArray[row] as [String:AnyObject]
         
         //let val:Int =   temp.value(forKey:"task") as! Int
         // print("task val: \(val)")
         //return (val + 1)%2
         //return (self.taskArray.object(at: row)as! NSDictionary)["task"]
         return swiftArray[row]["task"]
      }
      else if (tableColumn?.identifier == "description")
      {
         
         //  return (self.taskArray.object(at: row)as! NSDictionary)["description"]
         return swiftArray[row]["description"]
      }
      else if (tableColumn?.identifier == "util")
      {
         
         //return (self.taskArray.object(at: row)as! NSDictionary)["util"]
         return swiftArray[row]["util"]
      }
      
      return "***"
   }
   
   func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool
   {
      print ("shouldSelectRow row: \(row) ")
      
      return true
   }
   
   private func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int)
   {
      //(self.swiftArray[row] as! NSMutableDictionary).setObject(object!, forKey: (tableColumn?.identifier)! as NSCopying)
   }
   
   override var representedObject: Any?
      {
      didSet
      {
         print("representedObject")
      }
   }
   
}
