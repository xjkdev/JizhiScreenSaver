//
//  jizhi_saverView.swift
//  jizhi_saver
//
//  Created by 谢俊琨 on 2021/4/6.
//

import Foundation
import ScreenSaver
import CoreGraphics

class jizhi_saverView: ScreenSaverView {
    
    private enum Constants {
        static let bundleId: String = "com.xjkdev.jizhi-saver";
    }
    
    var mountains: [Mountain] = [];
    var height: Double = 0.0;
    var width: Double = 0.0;
    var extended_height : Double = 200.0;
    var base_height: Double = 50.0;
    var scale: Double = 2;
    var first_run: Bool = true;
    let verses_label = NSTextField();
    let poem_label = NSTextField();
    let author_label = NSTextField();
    let color_label = NSTextField();
    let background_light = NSColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0);
   
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
        
        super.init(frame: frame, isPreview: isPreview)
        
        self.addSubview(verses_label);
        self.addSubview(color_label);
        self.addSubview(poem_label);
        self.addSubview(author_label);
        
        self.configWidthHeight()
        self.configVersesLabel()
        self.configColorLabel()
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func draw(_ rect: NSRect) {
        if first_run || width != Double(bounds.maxX - bounds.minX) || height != Double(bounds.maxY - bounds.minY){
            configWidthHeight()
            
            first_run = false;
            let test_color = NSColor(red: 31.0/255, green: 32.0/255, blue: 64.0/255, alpha: 1.0)
            mountains = jizhi_saverView.growMountains(height: height, color: test_color, base_height: base_height)
            
            configVersesLabel()
            configColorLabel()
        }
        
        // Draw a single frame in this function
        drawBackground();
        
        for m in mountains {
            drawMountain(mountain: m)
        }
        
        
    }

    override func animateOneFrame() {
        super.animateOneFrame()
        // Update the "state" of the screensaver in this function
        self.animationTimeInterval = 1.0/30;
        setNeedsDisplay(NSRect(x: bounds.minX, y: bounds.minY, width: bounds.maxX-bounds.minX, height: CGFloat(base_height*5 + extended_height*scale)))
    }
    
    func configWidthHeight() {
        width = Double(bounds.maxX - bounds.minX);
        height = Double(bounds.maxY - bounds.minY);
        extended_height = height * 200.0 / 900.0;
        base_height = height * 50.0 / 900.0;
    }
    
    func drawBackground() {
        let background = NSBezierPath(rect: bounds)
        background_light.setFill()
        background.fill()
    }
    
    
    func drawMountain(mountain: Mountain) {
        var xoff: Double = 0;
        let p = NSBezierPath()
        mountain.c.setFill()
        
        p5noiseDetail(2, 1.3);
        
        for x in stride(from: 0, through: width+25*scale, by: 25*scale) {
            let yoff = p5map(n: p5noise(xoff + mountain.offset, mountain.t + mountain.offset), start1: 0, stop1: 1, start2: 0, stop2: extended_height);
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
    
    static func growMountains(height: Double, color: NSColor, base_height: Double) -> [Mountain] {
        var ret: [Mountain] = [];
        for i in 0..<5 {
            let c = NSColor(red:color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 1 - 0.2 * CGFloat(i))
            let h = base_height * Double(i);
            let mountain = Mountain(color: c, y: h);
            ret.append(mountain)
        }
        return ret;
    }

    func configVersesLabel() {
        let font_size_verses = min(0.04 * width, 30 + 0.01 * width);
        verses_label.frame = CGRect(origin: CGPoint(x: 0, y: 0.7 * height),
                                    size: CGSize(width: CGFloat(width), height: CGFloat(font_size_verses*1.5)))
        verses_label.backgroundColor = .none;
        
        let paraph = NSMutableParagraphStyle()
        paraph.alignment = .center
        let attrs: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: NSFont(name: "jiangxizhuokai-Regular", size: CGFloat(font_size_verses))!,
            NSAttributedString.Key.paragraphStyle: paraph,
        ]
        verses_label.attributedStringValue = NSAttributedString(string: "况夜鸟、啼绝四更头，边声起。",
                                                               attributes: attrs);
        verses_label.isBezeled = false
        
        verses_label.isEditable = false
        verses_label.alignment = .center
        verses_label.textColor = .black
        verses_label.autoresizingMask = [.width, .minYMargin, .maxYMargin]
        
        let font_size_poem = min(10+0.01*width, 0.022*width)
        let poem_y = Double(0.7 * height - font_size_verses*1);
        
        poem_label.backgroundColor = .none
        let attrs1: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: NSFont(name: "jiangxizhuokai-Regular", size: CGFloat(font_size_poem))!,
            NSAttributedString.Key.paragraphStyle: paraph,
        ]
        poem_label.attributedStringValue = NSAttributedString(string: "「满江红·代北燕南」",
                                                               attributes: attrs1);
        poem_label.isBezeled = false
        poem_label.isEditable = false
        poem_label.alignment = .center
        poem_label.textColor = .black
        poem_label.sizeToFit()
       
        author_label.backgroundColor = NSColor(red: 194/255, green: 0, blue: 0, alpha:1)
        let attrs2: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: NSFont(name: "jiangxizhuokai-Regular", size: CGFloat(font_size_poem)*0.67)!,
            NSAttributedString.Key.paragraphStyle: paraph,
        ]
        author_label.attributedStringValue = NSAttributedString(string: "纳兰性德",
                                                               attributes: attrs2);
        author_label.isBezeled = false
        author_label.isEditable = false
        author_label.alignment = .center
        author_label.textColor = .white
        author_label.layer?.cornerRadius = 3
        author_label.sizeToFit()
        
        let poem_height = Double(poem_label.frame.height);
        let poem_width = Double(poem_label.frame.width);
        let author_height = Double(author_label.frame.height);
        let author_width = Double(author_label.frame.width);
        let total_width = Double(author_width + poem_width);
        poem_label.frame.origin = CGPoint(x: width/2 - total_width/2 , y: poem_y)
        let a:Double = width/2 - total_width/2 + poem_width;
        let b:Double = poem_y + poem_height/2 - author_height/2;
        author_label.frame.origin = CGPoint(x: a, y: b);
    }
    
    func configColorLabel() {
        let font_size = min(0.15*width, 100 + 0.05*width);
        color_label.frame = CGRect(origin: CGPoint(x: width-0.9*font_size, y: 0),
                                    size: CGSize(width: CGFloat(font_size), height: CGFloat(height)))
        color_label.backgroundColor = .none;

        let paraph = NSMutableParagraphStyle()
        paraph.alignment = .right
        paraph.maximumLineHeight = CGFloat(font_size * 0.95);
        let attrs: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: NSFont(name: "jiangxizhuokai-Regular", size: CGFloat(font_size))!,
            NSAttributedString.Key.paragraphStyle: paraph,
        ]
        color_label.attributedStringValue = NSAttributedString(string: "晶\n石\n紫",
                                                               attributes: attrs);
        color_label.isBezeled = false
        color_label.isEditable = false
        color_label.textColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.1);
        color_label.autoresizingMask = [.minXMargin, .height]
    }
}
