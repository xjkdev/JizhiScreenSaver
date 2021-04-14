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
        static let background_light = NSColor(red: 230.0/255, green: 230.0/255, blue: 230.0/255, alpha: 1.0);
        static let background_dark = NSColor(red: 50.0/255, green: 50.0/255, blue: 50.0/255, alpha: 1.0);
        static let author_background = NSColor(red: 194.0/255, green: 0, blue: 0, alpha:1);
        static let color_text_light = NSColor(red: 0, green: 0, blue: 0, alpha: 0.1);
        static let color_text_dark = NSColor(red: 1, green: 1, blue: 1, alpha: 0.1);
        static let verses_text_light = NSColor(red: 17.0/255, green: 17.0/255, blue: 17.0/255, alpha: 1);
        static let verses_text_dark = NSColor(red: 1, green: 1, blue: 1, alpha: 1);
    }
    
    private var mountains: [Mountain] = [];
    private var mountain_layers: [CAShapeLayer] = [];
    private var height: CGFloat = 0.0;
    private var width: CGFloat = 0.0;
    private var first_run: Bool = true;
    private var is_dark_mode: Bool = false;
    
    private let verses_label = NSTextField();
    private let poem_label = NSTextField();
    private let author_label = NSTextField();
    private let color_label = NSTextField();
    
    private var wave_color: NSColor = NSColor(red: 31.0/255, green: 32.0/255, blue: 64.0/255, alpha: 1.0);
    private var color_name: String = "晶\n石\n紫";
    private var font_name: String = "jiangxizhuokai-Regular";
    private var verses_str: String = "况夜鸟、啼绝四更头，边声起。";
    private var poem_str: String = "「满江红·代北燕南」";
    private var author_str: String = "纳兰性德";
   
    class Mountain {
        let c : NSColor;
        var y : CGFloat=0.0;
        var offset: CGFloat=0.0;
        var t : CGFloat = 0.0;
        
        init(color: NSColor, y: CGFloat) {
            self.c = color;
            self.y = y;
            self.offset = CGFloat.random(in: 100...200);
            self.t = 0.0;
        }
    }
    
    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        
        super.init(frame: frame, isPreview: isPreview)
        
        self.recordWidthHeight()
        
        self.wantsLayer = true;
        
        let layer = CALayer()
        layer.frame = frame
        layer.backgroundColor = is_dark_mode ? Constants.background_dark.cgColor : Constants.background_light.cgColor;
        self.layer = layer
        for i in 0..<5 {
            let mlayer = CAShapeLayer()
            mlayer.frame = CGRect(x: 0, y: 0, width: frame.width,
                                  height: getBaseHeight() * CGFloat(i) + getExtendHeight())
            mlayer.path = CGMutablePath();
            mlayer.setNeedsDisplay();
            self.mountain_layers.append(mlayer);
            self.layer?.addSublayer(mlayer);
        }
        self.layer?.setNeedsDisplay()

        self.addSubview(verses_label);
        self.addSubview(color_label);
        self.addSubview(poem_label);
        self.addSubview(author_label);
        
        self.setWaveColor(name: "晶石紫", color: NSColor(red: 31.0/255, green: 32.0/255, blue: 64.0/255, alpha: 1.0))
        
        self.configVersesStyle()
        self.configColorStyle()
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func startAnimation() {
        self.animationTimeInterval = 1.0/30;
    }

    override func animateOneFrame() {
        super.animateOneFrame()
        
        if first_run || width != frame.width || height != frame.height{
            recordWidthHeight()
            first_run = false
            
            for i in 0..<5 {
                let mlayer = mountain_layers[i];
                mlayer.frame = CGRect(x: 0, y: 0, width: frame.width,
                                      height: getBaseHeight() * CGFloat(i) + getExtendHeight())
            }
            
            growMountains()
            configVersesStyle()
            configColorStyle()
        }
        
        
        for i in 0..<5 {
            let m = mountains[i];
            let layer = mountain_layers[i];
            drawMountain(layer: layer, mountain: m)
        }
    }
    
    func setWaveColor(name: String, color: NSColor) {
        color_name = Array(name).map(String.init).joined(separator: "\n")
        wave_color = color
        growMountains()
    }
    
    func setVerses(verses: String, by: String, from: String) {
        verses_str = verses;
        poem_str = from;
        author_str = by;
    }
    
    func recordWidthHeight() {
        width = frame.width;
        height = frame.height;
    }
    
    func getBaseHeight() -> CGFloat {
        return frame.height * 50.0 / 900.0;
    }
    
    func getExtendHeight() -> CGFloat {
        return frame.height * 200.0 / 900.0;
    }
    
    func drawMountain(layer: CAShapeLayer, mountain: Mountain) {
        var xoff: CGFloat = 0;
        layer.fillColor = mountain.c.cgColor;
        let p = CGMutablePath();
        
        p5noiseDetail(2, 1.3);
        
        for x in stride(from: 0, through: width+25, by: 25) {
            let yoff = p5map(n: p5noise(xoff + mountain.offset, mountain.t + mountain.offset), start1: 0, stop1: 1, start2: 0, stop2: getExtendHeight());
            let y = mountain.y  + yoff;

            if x == 0 {
                p.move(to: NSPoint(x: x, y: y))
            }else{
                p.addLine(to: NSPoint(x: x, y: y))
            }

            xoff += 0.08;
        }
        p.addLine(to: NSPoint(x: width + 100, y: 0));
        p.addLine(to: NSPoint(x: 0, y: 0));
        p.closeSubpath()

        mountain.t += 0.005;
        layer.path = p;
        layer.didChangeValue(forKey: "path")
    }
    
    func growMountains() {
        mountains = [];
        for i in 0..<5 {
            let c = NSColor(red:wave_color.redComponent,
                            green: wave_color.greenComponent,
                            blue: wave_color.blueComponent,
                            alpha: 1 - 0.2 * CGFloat(i))
            let h = getBaseHeight() * CGFloat(i);
            let mountain = Mountain(color: c, y: h);
            mountains.append(mountain)
        }
    }

    func configVersesStyle() {
        let font_size_verses = min(0.04 * width, 30 + 0.01 * width);
        verses_label.frame = CGRect(origin: CGPoint(x: 0, y: 0.7 * height),
                                    size: CGSize(width: width, height: font_size_verses*1.5))
        verses_label.backgroundColor = .none;
        
        let paraph = NSMutableParagraphStyle()
        paraph.alignment = .center
        paraph.lineHeightMultiple = 1
        let attrs: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: NSFont(name: font_name, size: font_size_verses) ?? .systemFont(ofSize: font_size_verses),
            NSAttributedString.Key.paragraphStyle: paraph,
        ]
        verses_label.attributedStringValue = NSAttributedString(string: verses_str, attributes: attrs);
        verses_label.isBezeled = false
        
        verses_label.isEditable = false
        verses_label.alignment = .center
        verses_label.textColor = is_dark_mode ? Constants.verses_text_dark : Constants.verses_text_light;
        verses_label.autoresizingMask = [.width, .minYMargin, .maxYMargin]
        
        let font_size_poem = min(10+0.01*width, 0.022*width)
        
        poem_label.backgroundColor = .none
        let attrs1: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: NSFont(name: font_name, size: font_size_poem) ?? .systemFont(ofSize: font_size_poem),
            NSAttributedString.Key.paragraphStyle: paraph,
        ]
        poem_label.attributedStringValue = NSAttributedString(string: poem_str, attributes: attrs1);
        poem_label.isBezeled = false
        poem_label.isEditable = false
        poem_label.alignment = .center
        poem_label.textColor = is_dark_mode ? Constants.verses_text_dark : Constants.verses_text_light;
        poem_label.sizeToFit()
        
        let font_size_author = font_size_poem*0.67;
        author_label.backgroundColor = Constants.author_background
        let attrs2: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: NSFont(name: font_name, size: font_size_author) ?? .systemFont(ofSize: font_size_author),
            NSAttributedString.Key.paragraphStyle: paraph,
        ]
        author_label.attributedStringValue = NSAttributedString(string: author_str, attributes: attrs2);
        author_label.isBezeled = false
        author_label.isEditable = false
        author_label.alignment = .center
        author_label.textColor = .white
        author_label.layer?.cornerRadius = 3
        author_label.sizeToFit()
        
        let poem_y = 0.7 * height - font_size_verses*1;
        let poem_height = poem_label.frame.height;
        let poem_width = poem_label.frame.width;
//        let author_height = author_label.frame.height;
        let author_width = author_label.frame.width;
        let total_width = author_width + poem_width;
        poem_label.frame.origin = CGPoint(x: width/2 - total_width/2 , y: poem_y)
        let a : CGFloat = width/2 - total_width/2 + poem_width;
        let b : CGFloat =  poem_y + poem_height * 0.1;
        author_label.frame.origin = CGPoint(x: a, y: b);
    }
    
    func configColorStyle() {
        let font_size = min(0.15*width, 100 + 0.05*width);
        color_label.frame = CGRect(origin: CGPoint(x: width-0.9*font_size, y: 0),
                                    size: CGSize(width: font_size, height: height))
        color_label.backgroundColor = .none;

        let paraph = NSMutableParagraphStyle()
        paraph.alignment = .right
        paraph.maximumLineHeight = font_size * 0.95;
        let attrs: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: NSFont(name: font_name, size: font_size) ?? .systemFont(ofSize: font_size),
            NSAttributedString.Key.paragraphStyle: paraph,
        ]
        color_label.attributedStringValue = NSAttributedString(string: color_name,
                                                               attributes: attrs);
        color_label.isBezeled = false
        color_label.isEditable = false
        color_label.textColor = is_dark_mode ? Constants.color_text_dark : Constants.color_text_light;
        color_label.autoresizingMask = [.minXMargin, .height]
    }
}
