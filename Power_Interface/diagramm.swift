//
//  diagramm.swift
//  Data_Interface
//
//  Created by Ruedi Heimlicher on 09.12.2016.
//  Copyright © 2016 Ruedi Heimlicher. All rights reserved.
//

import Foundation
import AVFoundation
import Darwin
import AppKit
import Cocoa


class DataPlot: NSView
{
   var DatenDicArray:[[String:CGFloat]]! = [[:]]
   var DatenArray:[[CGFloat]]! = [[]]
   var GraphArray = [CGMutablePath]( repeating: CGMutablePath(), count: 8 )
   var KanalArray = [1,0,0,0,0,0,0,0]
   var FaktorArray:[CGFloat]! = [CGFloat](repeating:0.5,count:8)
   var DatafarbeArray:[NSColor]! = [NSColor](repeating:NSColor.gray,count:8) // Strichfarbe im Diagramm
   
   var diagrammfeld:CGRect = CGRect.zero
  
   // var vorgaben = [[String:String]]()

   fileprivate struct   Geom
   {
      // Abstand von bounds
      static let randunten: CGFloat = 15.0
      static let randlinks: CGFloat = 0.0
      static let randoben: CGFloat = 10.0
      static let randrechts: CGFloat = 10.0
      // Abstand vom Feldrand
      static let offsetx: CGFloat = 0.0 // Offset des Nullpunkts
      static let offsety: CGFloat = 15.0
      static let freey: CGFloat = 20.0 // Freier Raum oben
      static let freex: CGFloat = 15.0 // Freier Raum rechts
   
   }
 
   
   
   fileprivate struct   Vorgaben
   {
      static var MajorTeileY: Int = 10                           // Teile der Hauptskala
      static var MinorTeileY: Int = 2                             // Teile der Subskala
      static var MaxY: CGFloat = 100.0                            // Obere Grenze der Anzeige
      static var MinY: CGFloat = 0.0                              // Untere Grenze der Anzeige
      static var MaxX: CGFloat = 1000                             // Obere Grenze der Abszisse

      static var ZeitKompression: CGFloat = 1.0
      static var Startsekunde: Int = 0
      static let NullpunktY: CGFloat = 0.0
      static let NullpunktX: CGFloat = 0.0
      static let DiagrammEcke: CGPoint = CGPoint(x:15, y:10)// Ecke des Diagramms im View
      static let DiagrammeckeY: CGFloat = 0.0 //
      static let StartwertX: CGFloat = 0.0 // Abszisse des ersten Wertew
      // static let StartwertY: CGFloat = 0.0
      
      // Achsen
      static let rastervertikal = 2 // Sprung innerhalb MajorTeileY + MinorTeileY
      
      
      static let majorrasterhorizontal = 50 // Sprung innerhalb Zeitachse
static let minorrasterhorizontal = 10
   }
   
   
   override convenience init(frame: CGRect)
   {
      self.init(frame:frame);
      Swift.print("DataPlot init")
      diagrammfeld = DiagrammRect(rect: self.bounds)
      // other code
   }

   required init(coder: NSCoder)
   {
      //Swift.print("DataPlot coder")
      super.init(coder: coder)!
      diagrammfeld = DiagrammRect(rect:  self.bounds)
      
   }


   open func setDatafarbe(farbe:NSColor, index:Int)
   {
      DatafarbeArray[index] = farbe
   }
 
   open func setVorgaben(vorgaben:[String:Double])
   {
      if (vorgaben["zeitkompression"] != nil)
      {
         Vorgaben.ZeitKompression = CGFloat(vorgaben["zeitkompression"]!)
      }
      Vorgaben.MajorTeileY = Int((vorgaben["MajorTeileY"])!)
   }
   
   open func setStartsekunde(startsekunde:Int)
   {
      Vorgaben.Startsekunde = startsekunde
   }

   open func setMaxX(maxX:Int)
   {
      Vorgaben.MaxX = CGFloat(maxX)
   }

   open func setMaxY(maxY:Int)
   {
      Vorgaben.MaxY = CGFloat(maxY)
   }

   open func setKanalArray(kanalArray:[Int])
   {
      KanalArray = kanalArray
   }

   
   open func setWerteArray(werteArray:[Float])
   {
 //     Swift.print("")
      let AnzeigeFaktor:CGFloat = 1.0//= maxSortenwert/maxAnzeigewert;
      let SortenFaktor:CGFloat = 1.0
      let feld = DiagrammRect(rect: self.bounds)
      //let FaktorX:CGFloat = (self.frame.size.width-15.0)/Vorgaben.MaxX		// Umrechnungsfaktor auf Diagrammbreite
      let FaktorX:CGFloat = feld.size.width/Vorgaben.MaxX
      
      //            //let FaktorY:CGFloat = (self.frame.size.height-(Geom.randoben + Geom.randunten))/Vorgaben.MaxY		// Umrechnungsfaktor auf Diagrammhoehe
      
      let FaktorY:CGFloat = feld.size.height / Vorgaben.MaxY
      //Swift.print("abszisse feld height: \(feld.size.height) Vorgaben.MaxY: \(Vorgaben.MaxY) FaktorY: \(FaktorY) ")

      
      //Swift.print("frame height: \(self.frame.size.height) FaktorY: \(FaktorY) ")
       var neuerPunkt:CGPoint = feld.origin
      neuerPunkt.x += (CGFloat(werteArray[0]) - CGFloat(Vorgaben.Startsekunde))*Vorgaben.ZeitKompression * FaktorX	//	Zeit, x-Wert, erster Wert im WerteArray

      var tempKanalDatenDic = [String:CGFloat]() //=  [CGFloat](repeating:0.0,count:8)
      tempKanalDatenDic["x"] = neuerPunkt.x
      for i in 0..<(werteArray.count-1) // erster Wert ist Abszisse
      {
         if (KanalArray[i] == 1)
         {
           neuerPunkt.y = feld.origin.y
//            Swift.print("i: \(i) werteArray 0: \(werteArray[0]) neuerPunkt.x nach: \(neuerPunkt.x)")
            
            let InputZahl = CGFloat(werteArray[i+1])	// Input vom teensy, 0-255
            
            let graphZahl = CGFloat(InputZahl - Vorgaben.MinY) * FaktorY 							// Red auf reale Diagrammhoehe
  //          Swift.print("i: \(i) InputZahl: \(InputZahl) graphZahl: \(graphZahl)")

            let rawWert = graphZahl * SortenFaktor
            tempKanalDatenDic[String(i)] = InputZahl
             let DiagrammWert = rawWert * AnzeigeFaktor
            //Swift.print("setWerteArray: Kanal: \(i) InputZahl:  \(InputZahl) graphZahl:  \(graphZahl) rawWert:  \(rawWert) DiagrammWert:  \(DiagrammWert)");
            FaktorArray[i] = 1/FaktorY //(Vorgaben.MaxY - Vorgaben.MinY)/(self.frame.size.height-(Geom.randoben + Geom.randunten))
            neuerPunkt.y += DiagrammWert;
            
            tempKanalDatenDic["np\(i)"] = neuerPunkt.y
            //neuerPunkt.y=InputZahl;
            //NSLog(@"setWerteArray: Kanal: %d MinY: %2.2F FaktorY: %2.2f",i,MinY, FaktorY);
            
            //NSLog(@"setWerteArray: Kanal: %d InputZahl: %2.2F FaktorY: %2.2f graphZahl: %2.2F rawWert: %2.2F DiagrammWert: %2.2F ",i,InputZahl,FaktorY, graphZahl,rawWert,DiagrammWert);
            
            //      NSString* tempWertString=[NSString stringWithFormat:@"%2.1f",InputZahl/2.0]
            //NSLog(@"neuerPunkt.y: %2.2f tempWertString: %@",neuerPunkt.y,tempWertString);
            let tempWertString = String(format: "%@%2.2f", "tempwertstring: ", InputZahl)
            
            
            
            // NSArray* tempDatenArray=[NSArray arrayWithObjects:[NSNumber numberWithFloat:neuerPunkt.x],[NSNumber numberWithFloat:neuerPunkt.y],tempWertString,nil]
            let tempDatenArray:[CGFloat] = [neuerPunkt.x, neuerPunkt.y, InputZahl, rawWert]
            
            
            //NSDictionary* tempWerteDic=[NSDictionary dictionaryWithObjects:tempDatenArray forKeys:[NSArray arrayWithObjects:@"x",@"y",@"wert",nil]]
            
            DatenArray.append(tempDatenArray) // verwendet fuer Scrolling
            
            //NSBezierPath* neuerGraph = NSBezierPath.bezierPath
            let neuerGraph = CGMutablePath()
            if (GraphArray[i].isEmpty) // letzter Punkt ist leer, Anfang eines neuen Linienabschnitts
            {
               Swift.print("GraphArray  von \(i) ist noch Empty")
               //neuerPunkt.x = Vorgaben.DiagrammEcke.x
               
               GraphArray[i].move(to: neuerPunkt)
             }
            else
            {
               //Swift.print("GraphArray von \(i) ist nicht mehr Empty")
               //[neuerGraph moveToPoint:[[GraphArray objectAtIndex:i]currentPoint]]//last Point
               //[neuerGraph lineToPoint:neuerPunkt]
               let currentpoint:CGPoint = GraphArray[i].currentPoint
               GraphArray[i].move(to:currentpoint)

               GraphArray[i].addLine(to:neuerPunkt)
               
            }
         }// if Kanal
         

         
      } // for i
      //Swift.print("tempKanalDatenDic: \t\(tempKanalDatenDic)\n")
      DatenDicArray.append(tempKanalDatenDic)
     // Swift.print("DatenDicArray: \n\(DatenDicArray)\n")
      needsDisplay = true
      //self.setNeedsDisplay(self.bounds)
      //self.displayIfNeeded()
   }
   
  
   
   override func draw(_ dirtyRect: NSRect)
   {
      super.draw(dirtyRect)
      let context = NSGraphicsContext.current()?.cgContext
      
      
  //    NSColor.white.setFill()
  //    NSRectFill(bounds)
      drawDiagrammInContext(context:context)
     
      

   }
   
 
   
}

extension Int
{
   var cgf: CGFloat { return CGFloat(self) }
   var f: Float { return Float(self) }
}

extension Float {
   var cgf: CGFloat { return CGFloat(self) }
}

extension Double {
   var cgf: CGFloat { return CGFloat(self) }
}

extension CGFloat {
   var f: Float { return Float(self) }
}
// MARK: - Drawing extension

extension DataPlot
{

   func initGraphArray()
   {
      for i in 0..<GraphArray.count
      {
         GraphArray[i] = CGMutablePath.init()
         
      }
   
   }

   
   func setDisplayRect()
   {
      Swift.print("setDisplayRect")
      self.setNeedsDisplay(self.bounds)
      

   }
   
   func drawRoundedRect(rect: CGRect, inContext context: CGContext?,
                        radius: CGFloat, borderColor: CGColor, fillColor: CGColor)
   {
      // 1
      let path = CGMutablePath()
      
      // 2
      path.move( to: CGPoint(x:  rect.midX, y:rect.minY ))
      path.addArc( tangent1End: CGPoint(x: rect.maxX, y: rect.minY ),
                   tangent2End: CGPoint(x: rect.maxX, y: rect.maxY), radius: radius)
      path.addArc( tangent1End: CGPoint(x: rect.maxX, y: rect.maxY ),
                   tangent2End: CGPoint(x: rect.minX, y: rect.maxY), radius: radius)
      path.addArc( tangent1End: CGPoint(x: rect.minX, y: rect.maxY ),
                   tangent2End: CGPoint(x: rect.minX, y: rect.minY), radius: radius)
      path.addArc( tangent1End: CGPoint(x: rect.minX, y: rect.minY ),
                   tangent2End: CGPoint(x: rect.maxX, y: rect.minY), radius: radius)
      path.closeSubpath()
      
      // 3
      context?.setLineWidth(1.0)
      context?.setFillColor(fillColor)
      context?.setStrokeColor(borderColor)
      
      // 4
      context?.addPath(path)
      context?.drawPath(using: .fillStroke)
   }
   
   /*
   func abszisse(rect: CGRect)->CGPath
   {
      let path = CGMutablePath()
      
      let abszissex = rect.origin.x + rect.size.width
      let bigmark = CGFloat(6)
      let submark = CGFloat(3)
      
      path.move(to: CGPoint(x:  abszissex, y: rect.origin.y ))
      //path.move(to: rect.origin)
      // linie nach oben
      path.addLine(to: CGPoint(x:  abszissex, y: rect.origin.y + rect.size.height))
      
      // wieder nach unten
      path.move(to: CGPoint(x:  abszissex, y: rect.origin.y ))
      //marken setzen
      let markdistanz = rect.size.height / (CGFloat(Vorgaben.MajorTeileY ) )
      let subdistanz = CGFloat(markdistanz) / CGFloat(Vorgaben.MinorTeileY)
      var posy = rect.origin.y
      for pos in 0...(Vorgaben.MajorTeileY - 1)
      {
         path.addLine(to: CGPoint(x:abszissex - bigmark, y: posy))
         
         // Wert
         let p = path.currentPoint
         let wert = pos
         let tempWertString = String(format: "%d",  wert)
         //Swift.print("p: \(p) tempWertString: \(tempWertString)")
         let paragraphStyle = NSMutableParagraphStyle()
         paragraphStyle.alignment = .right
         let attrs = [NSFontAttributeName: NSFont(name: "HelveticaNeue-Thin", size: 8)!, NSParagraphStyleAttributeName: paragraphStyle]
         
         tempWertString.draw(with: CGRect(x: p.x - 12 , y: p.y - 5, width: 10, height: 14), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
         
         var subposy = posy // aktuelle Position
         for sub in 1..<(Vorgaben.MinorTeileY)
         {
            subposy += subdistanz
            path.move(to: CGPoint(x:  abszissex, y: subposy ))
            path.addLine(to: CGPoint(x:abszissex - submark,y: subposy))
 
         }
         
          posy += markdistanz
         //posy = rect.origin.y + CGFloat(pos) * markdistanz
         path.move(to: CGPoint(x:  abszissex, y: posy))
         
      }
      path.addLine(to: CGPoint(x:abszissex - bigmark, y: posy))
      // Wert
      let p = path.currentPoint
      let wert = Vorgaben.MajorTeileY
      let tempWertString = String(format: "%d",  wert)
      //Swift.print("p: \(p) tempWertString: \(tempWertString)")
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .right
      let attrs = [NSFontAttributeName: NSFont(name: "HelveticaNeue-Thin", size: 8)!, NSParagraphStyleAttributeName: paragraphStyle]
      
      tempWertString.draw(with: CGRect(x: p.x - 12 , y: p.y - 5, width: 10, height: 14), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)

      
      return path
   }
  */
   func achsen(rect: CGRect)->CGPath
   {
      let path = CGMutablePath()
      
      let abszissestart = rect.origin.y
      let abszisseend = rect.origin.y + rect.size.height + 10
      
      let ordinatestart = rect.origin.x
      let ordinateend = rect.origin.x + rect.size.width + 10
      
      let bigmark = CGFloat(10)
      let submark = CGFloat(3)
      
      path.move(to: CGPoint(x: rect.origin.x , y: abszissestart ))
      //path.move(to: rect.origin)
      // linie nach oben
      path.addLine(to: CGPoint(x: rect.origin.x, y: abszisseend))
      // wieder nach unten
       path.move(to: CGPoint(x: ordinatestart , y: rect.origin.y ))
       path.addLine(to: CGPoint(x: ordinateend , y: rect.origin.y))
      
      
      //marken setzen
      
      
      return path
   }
   
   func horizontalelinen(rect: CGRect)->CGPath
   {
      let path = CGMutablePath()
      
      
      let liniestart = rect.origin.x
      let linieend = rect.origin.x + rect.size.width
      
      let bigmark = CGFloat(10)
      let submark = CGFloat(3)
      
      let deltay = rect.size.height / CGFloat(Vorgaben.MajorTeileY)  * CGFloat(Vorgaben.rastervertikal)
      var posy = rect.origin.y
      for pos in 0...(Vorgaben.MajorTeileY )
      {
         if ((pos > 0) && (( pos % Vorgaben.rastervertikal ) == 0))
         {
            let s = (Vorgaben.rastervertikal % pos)
            //Swift.print("pos: \(pos) y: \(rect.origin.y +  CGFloat(pos / Vorgaben.rastervertikal) * CGFloat(deltay))")
            path.move(to: CGPoint(x: liniestart , y: rect.origin.y +  CGFloat(pos / Vorgaben.rastervertikal) * CGFloat(deltay)))
            //path.move(to: rect.origin)
            // linie nach rechts
            path.addLine(to: CGPoint(x: linieend, y: rect.origin.y  +  CGFloat(pos / Vorgaben.rastervertikal) * CGFloat(deltay)))

         }
      }
      path.move(to: CGPoint(x: liniestart , y: rect.origin.y ))
      //path.move(to: rect.origin)
      // linie nach rechts
      path.addLine(to: CGPoint(x: linieend, y: rect.origin.y))
      // wieder nach links
      
      
      
      
      return path
   }
   
   func vertikalelinen(rect: CGRect, abszisse: CGFloat)->CGPath
   {
      
      let path = CGMutablePath()
      let bigmark = CGFloat(10)
      let submark = CGFloat(4)
      
      let liniestart = rect.origin.y
      let linieend = rect.origin.y + rect.size.height
      
      let markend = rect.origin.y + submark
      
      //let deltax = rect.size.height / CGFloat(Vorgaben.MajorTeileY)  * CGFloat(Vorgaben.rastervertikal)
      //var posy = rect.origin.y
      // if ((Int(abszisse) % Vorgaben.rasterhorizontal) == 0)
      
      for pos in Int(rect.origin.x)..<Int(abszisse)
      {
         if (pos % Vorgaben.minorrasterhorizontal == 0)
         {
            let posx =  CGFloat(pos)
            //Swift.print("vertikaleline posx: \(posx) liniestart: \(liniestart) linieend: \(linieend))")
            path.move(to: CGPoint(x: posx, y: liniestart ))
            
            if ((pos > 0)&&(pos % Vorgaben.majorrasterhorizontal == 0))
            {
               //path.move(to: rect.origin)
               // linie nach oben
               path.addLine(to: CGPoint(x: posx, y: linieend ))
               
               let labelfarbe = NSColor.init(red:0.5,green: 0.8, blue: 0.5,alpha:1.0)
               let tempWertString = String(format: "%d",  pos)
               //         Swift.print("i: \(i) p.y: \(p.y) wert: \(wert) tempWertString: \(tempWertString) DatenArray.last: \(DatenArray.last)")
               let paragraphStyle = NSMutableParagraphStyle()
               paragraphStyle.alignment = .center
               
               let attrs = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 10)!, NSParagraphStyleAttributeName: paragraphStyle ,NSForegroundColorAttributeName: labelfarbe]
               tempWertString.draw(with: CGRect(x: posx-20, y: liniestart-16, width: 40, height: 14), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)

               
            }
            else
            {
               path.addLine(to: CGPoint(x: posx, y: markend ))
            }
         }
      }
      
      return path
   }
   
   
   

   
   func drawDiagrammRect(rect: CGRect, inContext context: CGContext?,
                         borderColor: CGColor, fillColor: CGColor)
   {
      /*
       Diagramm im Plotrect zeichnen
       */
      var path = CGMutablePath()
      
      path.addRect(rect)
      
      // Feld fuer das Diagramm
      //  let diagrammrect = CGRect.init(x: rect.origin.x + Geom.offsetx, y: rect.origin.y + Geom.offsety, width: rect.size.width - Geom.offsetx - Geom.freex , height: rect.size.height - Geom.offsety - Geom.freey)
     // diagrammfeld = DiagrammRect(rect: PlotRect())

   //   diagrammfeld = DiagrammRect(rect: self.bounds)
      
      let x = rect.origin.x
      let y = rect.origin.y
      let a = rect.origin.x + rect.size.width
      let b = rect.origin.y + rect.size.height
      
      path.move(to: CGPoint(x:  diagrammfeld.origin.x, y: diagrammfeld.origin.y ))
      path.addLine(to: NSMakePoint(diagrammfeld.origin.x + diagrammfeld.size.width, diagrammfeld.origin.y )) // > rechts
      path.addLine(to: NSMakePoint(diagrammfeld.origin.x + diagrammfeld.size.width, diagrammfeld.origin.y + diagrammfeld.size.height)) // > oben
      path.addLine(to: NSMakePoint(diagrammfeld.origin.x , diagrammfeld.origin.y + diagrammfeld.size.height)) // > links
      path.addLine(to: NSMakePoint(diagrammfeld.origin.x , diagrammfeld.origin.y))
      //    path.addLine(to: NSMakePoint(diagrammrect.origin.x + diagrammrect.size.width, diagrammrect.origin.y + diagrammrect.size.height))
      path.closeSubpath()
      
      context?.setLineWidth(0.4)
      context?.setFillColor(fillColor)
      context?.setStrokeColor(borderColor)
      
      // 4
 //     context?.addPath(path)
      // context?.drawPath(using: .fillStroke)
      var achsenfeld = diagrammfeld
      achsenfeld.origin.x = 0
      let achsenpath = achsen(rect:achsenfeld)
      context?.setLineWidth(0.4)
      context?.addPath(achsenpath)
      
      var horizontalelinenfeld = self.diagrammfeld
      let horizontalelinenpfad = horizontalelinen(rect:horizontalelinenfeld)
      
      context?.addPath(horizontalelinenpfad)

      context?.drawPath(using: .stroke)
      
      let abszissebreite = CGFloat(10.0)
      var abszisserect = diagrammfeld
      abszisserect.size.width = abszissebreite
      abszisserect.origin.x -= abszissebreite
      let abszissefarbe = CGColor.init(red:0.0,green:0.5, blue: 0.5,alpha:1.0)
 
      /*
      let abszissepath = abszisse(rect:abszisserect)
      // let abszissepath = abszisse(rect:rect,linienfarbe:borderColor)
      context?.setLineWidth(1.0)
      context?.addPath(abszissepath)
      context?.setStrokeColor(abszissefarbe)
      //context?.setFillColor(CGColor.init(red:0x00,green: 0xFF, blue: 0xFF,alpha:1.0))
      context?.drawPath(using: .stroke)
      */
      
      let lastdata = DatenDicArray.last
      let lastdatax = lastdata?["x"]
      let lastdatay = lastdata?["0"]
      
      if ((lastdatax) != nil)
      {
         let vertikalpfad = vertikalelinen(rect: diagrammfeld, abszisse: CGFloat(lastdatax!))
         context?.setLineWidth(0.4)
         context?.addPath(vertikalpfad)
         context?.drawPath(using: .stroke)
      }
      
      for i in  0..<GraphArray.count
      {
         if (GraphArray[i].isEmpty)
         {
            //Swift.print("GraphArray von \(i) ist Empty")
            continue
         }
         else
         {
            //Swift.print("GraphArray von \(i) ist nicht Empty")
         }
         //Swift.print("GraphArray not Empty")
         
         //GraphArray[0].addLine(to: NSMakePoint(diagrammrect.origin.x + diagrammrect.size.width, diagrammrect.origin.y + diagrammrect.size.height))
         //GraphArray[0].closeSubpath()
         let tempgreen = CGFloat((0xA0 + (i * 20) & 0xFF))
         let linienfarbe = CGColor.init(red:0.0,green: 0.0, blue: 1.0,alpha:1.0)
         
         context?.setLineWidth(1.5)
         //    context?.setFillColor(fillColor)
         context?.setStrokeColor(DatafarbeArray[i].cgColor)
         
         // 4
         context?.addPath(GraphArray[i])
         //context?.beginPath()
         context?.drawPath(using: .stroke)
         
         let wert = lastdata?[String(i)]
 //        Swift.print("diagramm lastdatax: \(lastdatax!)")

         //         Swift.print("i: \(i) qlastx: \(qlastx) qlasty: \(qlasty) wert: \(wert)\n")
         
         //https://www.hackingwithswift.com/example-code/core-graphics/how-to-draw-a-text-string-using-core-graphics
         let p = GraphArray[i].currentPoint
         //Swift.print("diagramm p x: \(p.x)")
         
         //         Swift.print("qlastx: \(qlastx)  DatenDicArray: \n\(DatenDicArray)")
         //         let a = DatenDicArray.filter{$0["x"] == qlasty}
         //         Swift.print("a: \(a)")
         //let lasty = DatenArray.last?[i+1]
         
         //let labelfarbe = CGColor.init(red:1.0,green: 1.0, blue: 0.0,alpha:1.0)
         let labelfarbe = NSColor.init(red:0.5,green: 0.8, blue: 0.5,alpha:1.0)
         let tempWertString = String(format: "%2.1f",  wert!)
         //         Swift.print("i: \(i) p.y: \(p.y) wert: \(wert) tempWertString: \(tempWertString) DatenArray.last: \(DatenArray.last)")
         let paragraphStyle = NSMutableParagraphStyle()
         paragraphStyle.alignment = .left
         
         let attrs = [NSFontAttributeName: NSFont(name: "HelveticaNeue", size: 10)!, NSParagraphStyleAttributeName: paragraphStyle ,NSForegroundColorAttributeName: DatafarbeArray[i]]
         tempWertString.draw(with: CGRect(x: p.x + 4, y: p.y-6, width: 40, height: 14), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
         
         
      }
      
      

      context?.drawPath(using: .stroke)
      //Swift.print("GraphArray drawPath end")
   }
   
   
   func PlotRect() -> CGRect
   {
      let breite = bounds.size.width  -  Geom.randlinks - Geom.randrechts
      let hoehe = bounds.size.height - Geom.randoben - Geom.randunten
      let rect = CGRect(x: Geom.randlinks,
                        y: Geom.randunten ,
                        width: breite, height: hoehe)
      return rect
   }

   func DiagrammFeld() -> CGRect
   {
      return diagrammfeld
   }
   
   func DiagrammFeldHeight()->CGFloat
   {
      //Swift.print("")
      return diagrammfeld.size.height
   }
   
   func setDiagrammFeldHeight(h:CGFloat)
   {
      
      diagrammfeld.size.height = h
   }

   func DiagrammRect(rect: CGRect) -> CGRect
   {
          // let diagrammrect = CGRect.init(x: rect.origin.x + Geom.offsetx, y: rect.origin.y + Geom.offsety, width: rect.size.width - Geom.offsetx - Geom.freex , height: rect.size.height - Geom.offsety - Geom.freey)
      
      let diagrammrect = CGRect.init(x: rect.origin.x + Geom.offsetx, y: rect.origin.y + Geom.offsety  + Geom.offsety, width: rect.size.width - Geom.offsetx - Geom.freex  - Geom.randrechts  -  Geom.randlinks, height: rect.size.height - Geom.offsety - Geom.freey  - Geom.randoben - Geom.randunten)
      return diagrammrect
   }
   
   func drawDiagrammInContext(context: CGContext?)
   {
      context!.setLineWidth(0.6)
      //let diagrammRect = PlotRect()
      let randfarbe =  CGColor.init(red:1.0,green: 0.0, blue: 0.0,alpha:1.0)
      let feldfarbe = CGColor.init(red:0.8,green: 0.8, blue: 0.0,alpha:1.0)
      let linienfarbe = CGColor.init(red:0.0,green: 0.0, blue: 1.0,alpha:1.0)
     
      drawDiagrammRect(rect: diagrammfeld, inContext: context,
               borderColor: randfarbe,
               fillColor: feldfarbe)
   
      self.setNeedsDisplay(self.frame)
   }
   
   
   func drawLinesInContext(context: CGContext?,start: CGPoint, data: [[Double]], linewidth:[Double])
   {
      
      
      //for templinie in data // Linien in data zu graph zusammensetzen
      for i in (0..<data.count)
      {
         if (data[i].count > 1) // mindestens ein paket
         {
            var temppath = CGMutablePath()
            
            temppath.move(to: CGPoint(x:  (start.x + CGFloat(data[i][0])), y: (start.y + CGFloat(data[i][0]))))

           }
      }
      //context!.setLineWidth(linewidth)
      
   }
   
   func backgroundColor_n(color: NSColor)
   {
      wantsLayer = true
      layer?.backgroundColor = color.cgColor
   }

 
}

class Abszisse: DataPlot
{
   fileprivate struct abszvorgaben
   {
      static let legendebreite: CGFloat = 10.0
      static let exponent: Int = 1 // Zehnerpotenz fuer label
   }


   required init(coder aDecoder: NSCoder)
   {
      //Swift.print("abszisse init coder")
      super.init(coder: aDecoder)
      diagrammfeld = DiagrammRect(rect:self.bounds)
      //diagrammfeld = PlotRect()
   }

   override func PlotRect() -> CGRect
   {
      Swift.print("abszisse PlotRect bounds: \(bounds)")
      let breite = bounds.size.width // -  Geom.randlinks - Geom.randrechts
      let hoehe = bounds.size.height - Geom.randoben - Geom.randunten
      let rect = CGRect(x:0 ,
                        y: Geom.randunten ,
                        width: breite, height: hoehe)
      Swift.print("abszisse PlotRect rect: \(rect)")
      return rect
   }
 
   func abszisse(rect: CGRect)->CGPath
   {
      let path = CGMutablePath()
      
      let abszissex = rect.origin.x + rect.size.width - abszvorgaben.legendebreite
      let bigmark = CGFloat(6)
      let submark = CGFloat(3)
      
      path.move(to: CGPoint(x:  abszissex, y: rect.origin.y ))
      //path.move(to: rect.origin)
      // linie nach oben
      path.addLine(to: CGPoint(x:  abszissex, y: rect.origin.y + rect.size.height))
      
      // wieder nach unten
      path.move(to: CGPoint(x:  abszissex, y: rect.origin.y ))
      //marken setzen
      let markdistanz = rect.size.height / (CGFloat(Vorgaben.MajorTeileY ) )
      let subdistanz = CGFloat(markdistanz) / CGFloat(Vorgaben.MinorTeileY)
      var posy = rect.origin.y
      let deznummer = NSDecimalNumber(decimal:pow(10,abszvorgaben.exponent)).intValue

      for pos in 0...(Vorgaben.MajorTeileY - 1)
      {
         path.addLine(to: CGPoint(x:abszissex - bigmark, y: posy))
         
         if (( pos % Vorgaben.rastervertikal ) == 0)
         {
            // Wert
            let p = path.currentPoint
            let zehnerpotenz = pow(10,abszvorgaben.exponent)
            let wert = pos * deznummer
            let tempWertString = String(format: "%d",  wert)
            //Swift.print("p: \(p) tempWertString: \(tempWertString)")
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .right
            let attrs = [NSFontAttributeName: NSFont(name: "HelveticaNeue-Thin", size: 8)!, NSParagraphStyleAttributeName: paragraphStyle]
            
            tempWertString.draw(with: CGRect(x: p.x - 42 , y: p.y - 5, width: 40, height: 14), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
         }
         
         var subposy = posy // aktuelle Position
         for _ in 1..<(Vorgaben.MinorTeileY)
         {
            subposy += subdistanz
            path.move(to: CGPoint(x:  abszissex, y: subposy ))
            path.addLine(to: CGPoint(x:abszissex - submark,y: subposy))
            
         }
         
         posy += markdistanz
         //posy = rect.origin.y + CGFloat(pos) * markdistanz
         path.move(to: CGPoint(x:  abszissex, y: posy))
         
      }
      path.addLine(to: CGPoint(x:abszissex - bigmark, y: posy))
      // Wert
      
      let p = path.currentPoint
      let wert = Vorgaben.MajorTeileY * deznummer
      let tempWertString = String(format: "%d",  wert)
      //Swift.print("p: \(p) tempWertString: \(tempWertString)")
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .right
      let attrs = [NSFontAttributeName: NSFont(name: "HelveticaNeue-Thin", size: 8)!, NSParagraphStyleAttributeName: paragraphStyle]
      
      tempWertString.draw(with: CGRect(x: p.x - 42 , y: p.y - 5, width: 40, height: 14), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
      
      
      return path
   }


}

extension Abszisse
{
   
   override    func DiagrammRect(rect: CGRect) -> CGRect
   {
      // let diagrammrect = CGRect.init(x: rect.origin.x + Geom.offsetx, y: rect.origin.y + Geom.offsety, width: rect.size.width - Geom.offsetx - Geom.freex , height: rect.size.height - Geom.offsety - Geom.freey)
      
      let diagrammrect = CGRect.init(x: rect.origin.x +  rect.size.width  , y: rect.origin.y + Geom.offsety + Geom.randunten, width: rect.size.width  , height: rect.size.height - Geom.offsety - Geom.freey)
      return diagrammrect
   }
   
   
   override func DiagrammFeld() -> CGRect
   {
      return diagrammfeld
   }
   

   override func drawDiagrammRect(rect: CGRect, inContext context: CGContext?,
                         borderColor: CGColor, fillColor: CGColor)
   {
      /*
       Diagramm im Plotrect zeichnen
       */
      var path = CGMutablePath()
      
      //path.addRect(rect)
      
      // Feld fuer das Diagramm
      //  let diagrammrect = CGRect.init(x: rect.origin.x + Geom.offsetx, y: rect.origin.y + Geom.offsety, width: rect.size.width - Geom.offsetx - Geom.freex , height: rect.size.height - Geom.offsety - Geom.freey)
      // diagrammfeld = DiagrammRect(rect: PlotRect())
      
      //let diagrammrect = DiagrammRect(rect: PlotRect())
      
      let x = rect.origin.x
      let y = rect.origin.y
      let a = rect.origin.x + rect.size.width
      let b = rect.origin.y + rect.size.height
      /*
      path.move(to: CGPoint(x:  diagrammfeld.origin.x, y: diagrammfeld.origin.y ))
      path.addLine(to: NSMakePoint(diagrammfeld.origin.x + diagrammfeld.size.width, diagrammfeld.origin.y )) // > rechts
      path.addLine(to: NSMakePoint(diagrammfeld.origin.x + diagrammfeld.size.width, diagrammfeld.origin.y + diagrammfeld.size.height)) // > oben
      path.addLine(to: NSMakePoint(diagrammfeld.origin.x , diagrammfeld.origin.y + diagrammfeld.size.height)) // > links
      path.addLine(to: NSMakePoint(diagrammfeld.origin.x , diagrammfeld.origin.y))
      //    path.addLine(to: NSMakePoint(diagrammrect.origin.x + diagrammrect.size.width, diagrammrect.origin.y + diagrammrect.size.height))
      path.closeSubpath()
      
      context?.setLineWidth(1.5)
      context?.setFillColor(fillColor)
      context?.setStrokeColor(borderColor)
      */
      // 4
      //     context?.addPath(path)
      // context?.drawPath(using: .fillStroke)
      //let achsenpath = achsen(rect:diagrammfeld)
      //context?.addPath(achsenpath)
      let abszissebreite = CGFloat(10.0)
      var abszisserect = diagrammfeld
      abszisserect.size.width = abszissebreite
      abszisserect.origin.x -= 1
      let abszissefarbe = CGColor.init(red:0.0,green:0.5, blue: 0.5,alpha:1.0)
      
      
       let abszissepath = abszisse(rect:abszisserect)
       // let abszissepath = abszisse(rect:rect,linienfarbe:borderColor)
       context?.setLineWidth(1.0)
       context?.addPath(abszissepath)
       context?.setStrokeColor(abszissefarbe)
       //context?.setFillColor(CGColor.init(red:0x00,green: 0xFF, blue: 0xFF,alpha:1.0))
       context?.drawPath(using: .stroke)
      
      

      //context?.drawPath(using: .stroke)
      //Swift.print("GraphArray drawPath end")
   }
   
}



class datadiagramm: NSViewController, NSWindowDelegate
{
   @IBOutlet var subview: NSView!
   @IBOutlet weak var graph: NSView!
   @IBOutlet weak var titel: NSTextField!

   required init?(coder aDecoder: NSCoder)
   {
      print("init coder")
      super.init(coder: aDecoder)
   }
   
   override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
   {
      super.init(nibName: nibNameOrNil, bundle: nil)!

   }
   override func viewDidLoad()
   {
      super.viewDidLoad()
      print("datadiagramm viewDidLoad")
      titel.stringValue = "Diagramm"
   }
   
 
}

