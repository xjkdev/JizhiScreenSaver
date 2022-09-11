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
    private var height: CGFloat = 0.0;
    private var width: CGFloat = 0.0;
    private var first_run: Bool = true;
    private var is_dark_mode: Bool = false;
    
    private var verses_list: [Verses] = [];
    private var verses_view: VersusView? = nil;
    private let color_label = NSTextField();
    
    private var wave_colors: [WaveColor] = [];
    private var wave_color: WaveColor = WaveColor.defaultColor;
    
    private var font_name: String = "jiangxizhuokai-Regular";
    
    private var jinrishici_token: String = "";
    
    struct WaveColor {
        var name : String;
        var red, green, blue: Int;
        
        var lightSuitable: Bool = true;
        var darkSuitable: Bool = true;
        
        static let defaultColor = WaveColor(name: "晶石紫", red: 31, green: 32, blue: 64);
        
        func getColor() -> NSColor {
            return NSColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1.0);
        }
        
        func getNameLines() -> String {
            return Array(name).map(String.init).joined(separator: "\n")
        }
    }
    
    struct Verses {
        var verses: String;
        var title: String;
        var author: String;
        
        static let defaultVerses = Verses(verses: "况夜鸟、啼绝四更头，边声起。", title: "「满江红·代北燕南」", author: "纳兰性德")
    }
   
    class Mountain {
        let c : NSColor;
        var y : CGFloat=0.0;
        var offset: CGFloat=0.0;
        var t : CGFloat = 0.0;
        var layer: CAShapeLayer
        
        init(color: NSColor, y: CGFloat, layer: CAShapeLayer) {
            self.c = color;
            self.y = y;
            self.offset = CGFloat.random(in: 100...200);
            self.t = 0.0;
            self.layer = layer;
        }
    }
    
    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
       
        super.init(frame: frame, isPreview: isPreview)
        
        self.recordWidthHeight()
        self.load_user_defaults()
        
        self.wantsLayer = true;
        let layer = CALayer()
        layer.frame = frame
        layer.backgroundColor = is_dark_mode ? Constants.background_dark.cgColor : Constants.background_light.cgColor;
        self.layer = layer
        self.layer?.setNeedsDisplay()
        
        self.load_wave_colors()
        self.setRandomWaveColor()
        self.load_verses()
        
       
        let verses =  self.request_jinrishici() ?? self.verses_list.randomElement() ?? Verses.defaultVerses
        
        self.verses_view = VersusView(frame: NSRect(origin: CGPoint(x: 0, y: 0.7*frame.height),
                                                    size: CGSize(width: frame.width, height: 0.05*frame.width)),
                                      verses: verses.verses,
                                      from: verses.title,
                                      by: verses.author,
                                      isDarkMode: is_dark_mode,
                                      font: font_name)
        
        self.verses_view?.autoresizingMask = [.width, .minYMargin, .maxYMargin, .height]

        self.growMountains()
        self.configColorStyle()
        
        self.addSubview(self.verses_view!)
        self.addSubview(self.color_label);
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func animateOneFrame() {
        super.animateOneFrame()
        
        if width != frame.width || height != frame.height{
            recordWidthHeight()
            first_run = false
            
            growMountains()
            configColorStyle()
        }
        
        
        for i in 0..<5 {
            let m = mountains[i];
            drawMountain(mountain: m)
        }
    }
    
    func request_jinrishici() -> Verses?{
        let session = URLSession.shared;
//        // problem: make two request will lead to failure of the second.
//        if jinrishici_token == "" {
//            let semaphore = DispatchSemaphore(value: 0)
//            let url = URL(string: "https://v2.jinrishici.com/token")!
//            let task = session.dataTask(with: url) { [self](data, response, error) in
//                guard let data = data else { return }
//                do {
//                    let jsonResult = try JSONSerialization.jsonObject(with: data, options:.mutableLeaves)
//                    if let result = jsonResult as? Dictionary<String, String> {
//                        if result["status"] == "success" {
//                            self.jinrishici_token = result["data"] ?? ""
//                        }
//                    }
//                } catch {
//                    NSLog("Json decode error1")
//                }
//                print(self.jinrishici_token)
//                if self.jinrishici_token != "" {
//                    let bundleIdentifier = Bundle(for: jizhi_saverView.self).bundleIdentifier!
//                    let database = ScreenSaverDefaults(forModuleWithName: bundleIdentifier) ?? UserDefaults()
//                    database.setValue(self.jinrishici_token, forKey: "jinrishici_token")
//                }
//                semaphore.signal()
//            }
//            task.resume()
//            _ = semaphore.wait(timeout: .distantFuture)
//        }
        
        let semaphore = DispatchSemaphore(value: 0)
        let url = URL(string: "https://v2.jinrishici.com/sentence")!
        var url_req = URLRequest(url: url)
        if self.jinrishici_token != "" {
            url_req.setValue(self.jinrishici_token, forHTTPHeaderField: "X-User-Token")
        }
        
        var ret_verses : Verses? = nil
        let task1 = session.dataTask(with: url_req) {(data, response, error) in
            guard let data = data else { return }
            do {
                let jsonResult = try JSONSerialization.jsonObject(with: data, options:.mutableLeaves)
                if let result = jsonResult as? Dictionary<String, Any> {
                    if let status = result["status"] as? String, let data = result["data"] as? Dictionary<String, Any>{
                        if status == "success" {
                            ret_verses = jizhi_saverView.decodeVerses(from: data)
                            if ret_verses != nil {
                                NSLog("jinrishici: %@", ret_verses!.verses)
                            }
                        }
                    }
                }
            } catch {
                NSLog("Json decode error2")
            }
            semaphore.signal()
        }
        task1.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        return ret_verses
    }
    
    func setRandomWaveColor() {
        if wave_colors.count > 0 {
            var color = wave_colors.randomElement()!
            while (is_dark_mode && !color.darkSuitable) || (!is_dark_mode && !color.lightSuitable) {
                color = wave_colors.randomElement()!
            }
            setWaveColor(color)
        }else{
            setWaveColor(.defaultColor)
        }
    }
    
    func setWaveColor(_ color: WaveColor) {
        self.wave_color = color;
        growMountains()
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
    
    func drawMountain(mountain: Mountain) {
        var xoff: CGFloat = 0;
        let layer = mountain.layer;
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
        layer.didChangeValue(for: \.path)
    }
    
    func growMountains() {
        let is_first_run = (mountains.count == 0);
        let original_color = wave_color.getColor();
        for i in 0..<5 {
            
            let c = NSColor(red: original_color.redComponent,
                            green: original_color.greenComponent,
                            blue: original_color.blueComponent,
                            alpha: 1 - 0.2 * CGFloat(i))
            let h = getBaseHeight() * CGFloat(i);
            
            let mlayer = is_first_run ? CAShapeLayer() : mountains[i].layer;
            mlayer.frame = CGRect(x: 0, y: 0, width: frame.width,
                                  height: h + getExtendHeight())
            mlayer.fillColor = c.cgColor;
            mlayer.setNeedsDisplay();
            let m = Mountain(color: c, y: h, layer: mlayer);
            if is_first_run {
                mountains.append(m)
                self.layer?.addSublayer(m.layer)
            }else{
                mountains[i] = m;
            }
            drawMountain(mountain: m)
        }
    }
    
    func configColorStyle() {
        let font_size = min(0.15*width, 100 + 0.05*width);
        color_label.frame = CGRect(origin: CGPoint(x: width-0.95*font_size, y: 0),
                                    size: CGSize(width: font_size, height: height))
        color_label.backgroundColor = .none;

        let paraph = NSMutableParagraphStyle()
        paraph.alignment = .right
        paraph.maximumLineHeight = font_size * 0.95;
        let attrs: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: NSFont(name: font_name, size: font_size) ?? .systemFont(ofSize: font_size),
            NSAttributedString.Key.paragraphStyle: paraph,
        ]
        color_label.attributedStringValue = NSAttributedString(string: wave_color.getNameLines(),
                                                               attributes: attrs);
        color_label.isBezeled = false
        color_label.isEditable = false
        color_label.textColor = is_dark_mode ? Constants.color_text_dark : Constants.color_text_light;
        color_label.autoresizingMask = [.minXMargin, .height]
    }
    
    func load_wave_colors() {
        if let path = Bundle(for: jizhi_saverView.self).path(forResource: "wavesColors", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Array<AnyObject> {
                    for colorResult in jsonResult {
                        if let color = colorResult as? Dictionary<String, AnyObject> {
                            if let name = color["name"] as? String,
                               let lightSuitable = color["lightSuitable"] as? Bool,
                               let RGB = color["RGB"] as? Array<Int>,
                               let darkSuitable = color["darkSuitable"] as? Bool {
                                let color = WaveColor(name: name, red: RGB[0], green: RGB[1], blue: RGB[2], lightSuitable: lightSuitable, darkSuitable: darkSuitable)
                                wave_colors.append(color);
                            }
                        }
                    }
                }
            } catch {
                NSLog("jizhi: error11")
                wave_colors.append(.defaultColor)
            }
        }else{
            NSLog("jizhi: error21")
            wave_colors.append(.defaultColor)
        }
    }
    
    func load_verses() {
        if let path = Bundle(for: jizhi_saverView.self).path(forResource: "shici", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Array<AnyObject> {
                    for shiciResult in jsonResult {
                        if let shici = shiciResult as? Dictionary<String, AnyObject>, let verses = jizhi_saverView.decodeVerses(from: shici) {
                            verses_list.append(verses)
                        }
                    }
                }
            } catch {
                NSLog("jizhi: error12")
                verses_list.append(.defaultVerses)
            }
        }else{
            NSLog("jizhi: error22")
            verses_list.append(.defaultVerses)
        }
    }
    
    func load_user_defaults() {
        let bundleIdentifier = Bundle(for: jizhi_saverView.self).bundleIdentifier!
        var database : UserDefaults = UserDefaults()
        if let mainbundleid = Bundle.main.bundleIdentifier, bundleIdentifier != mainbundleid {
            database = ScreenSaverDefaults(forModuleWithName: bundleIdentifier)!
        }
        
//        is_dark_mode = database.bool(forKey: "is_dark_mode")
//        font_name = database.string(forKey: "font_name") ?? NSFont.systemFont(ofSize: 1).fontName
//        jinrishici_token = database.string(forKey: "jinrishici_token") ?? ""
        
    }
    
    
    static func decodeVerses(from dictionary: Dictionary<String, Any>) -> Verses?{
        if let content = dictionary["content"] as? String,
           let origin = dictionary["origin"] as? Dictionary<String, AnyObject> {
            if let title = origin["title"] as? String,
               let author = origin["author"] as? String{
                return Verses(verses: content, title: title, author: author)
            }
        }
        
        return nil;
    }
}
