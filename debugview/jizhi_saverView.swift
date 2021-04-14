//
//  jizhi_saverView.swift
//  jizhi_saver
//
//  Created by 谢俊琨 on 2021/4/6.
//

import Foundation
import ScreenSaver
import CoreGraphics
import WebKit

class jizhi_saverView: ScreenSaverView {
    
    private enum Constants {
        static let bundleId: String = "com.xjkdev.jizhi-saver";
    }
    
    var wkview : WKWebView
    var mountains: [Mountain];
    var height: Double = 0.0;
    var width: Double = 0.0;
    var scale: Double = 1.0;
    var first_draw: Bool = true;
   
    class Mountain {
        let c : NSColor;
        var y : Double=0.0;
        var offset: Double=0.0;
        var t : Double = 0.0;
        
        init(color: NSColor, y: Double) {
            self.c = color;
            self.y = y;
            self.offset = Double.random(in: 100...200);
            self.t = 0.0;
        }
    }
    
    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
//        let color = NSColor(red: 249.0/255, green: 244.0/255, blue: 220.0/255, alpha: 1.0)
//        self.mountains = jizhi_saverView.growMountains(color: color)
//        width = Double(frame.width);
//        height = Double(frame.height);
        wkview = WKWebView(frame: frame)
        wkview.autoresizingMask = [.width, .height];
        wkview.loadHTMLString( testHtml.joined(), baseURL: nil)
        NSLog("%f %f", width, height)
        super.init(frame: frame, isPreview: isPreview)
        
        
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func draw(_ rect: NSRect) {
        // Draw a single frame in this function
   
//        drawBackground();
//
//        for m in mountains {
//            drawMountain(mountain: m)
//        }
    }

    override func animateOneFrame() {
        super.animateOneFrame()
//        wkview.evaluateJavaScript("document.", completionHandler: <#T##((Any?, Error?) -> Void)?##((Any?, Error?) -> Void)?##(Any?, Error?) -> Void#>)
        // Update the "state" of the screensaver in this function
//        self.animationTimeInterval = 1.0/30;
//        setNeedsDisplay(bounds)
    }
    
    func drawBackground() {
        let background = NSBezierPath(rect: bounds)
        let color = NSColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
        color.setFill()
        background.fill()
    }
    
    
    func drawMountain(mountain: Mountain) {
        var xoff: Double = 0;
        let p = NSBezierPath()
        let width = Double(bounds.maxX - bounds.minX)
        // let height = Double(bounds.maxY - bounds.minY)
        mountain.c.setFill()
        
        p5noiseDetail(1.7, 1.3);
        
        for x in stride(from: 0, through: width+25*scale, by: 25*scale) {
            let yoff = p5map(n: p5noise(xoff + mountain.offset, mountain.t + mountain.offset), start1: 0, stop1: 1, start2: 0, stop2: 200 );
            let y = mountain.y  + yoff;

            if x == 0 {
                p.move(to: NSPoint(x: x, y: y))
            }else{
                
                p.line(to: NSPoint(x: x, y: y))
            }


            xoff += 0.08;
        }
        p.line(to: NSPoint(x: width + 100 * scale, y: 0));
        p.line(to: NSPoint(x: 0, y: 0));
        p.close()
        p.fill()

        mountain.t += 0.005;
    }
    
    static func growMountains(color: NSColor) -> [Mountain] {
        var ret: [Mountain] = [];
        for i in 0..<5 {
            let c = NSColor(red:color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 1 - 0.2 * CGFloat(i))
            let h = 50.0 * Double(i);
            let mountain = Mountain(color: c, y: h);
            ret.append(mountain)
        }
        return ret;
    }

}
