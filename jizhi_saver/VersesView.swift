//
//  VersesView.swift
//  jizhi_saver
//
//  Created by 谢俊琨 on 2021/4/14.
//

import Foundation
import AppKit

class VersusView : NSView {
    private let verses_label = NSTextField();
    private let title_label = NSTextField();
    private let author_label = NSTextField();
    
    private var font_name: String = "jiangxizhuokai-Regular";
    private var verses_str: String = "况夜鸟、啼绝四更头，边声起。";
    private var title_str: String = "「满江红·代北燕南」";
    private var author_str: String = "纳兰性德";
    
    private var is_dark_mode: Bool = false;
    
    private enum Constants {
        static let author_background = NSColor(red: 194.0/255, green: 0, blue: 0, alpha:1);
        static let color_text_light = NSColor(red: 0, green: 0, blue: 0, alpha: 0.1);
        static let color_text_dark = NSColor(red: 1, green: 1, blue: 1, alpha: 0.1);
        static let verses_text_light = NSColor(red: 17.0/255, green: 17.0/255, blue: 17.0/255, alpha: 1);
        static let verses_text_dark = NSColor(red: 1, green: 1, blue: 1, alpha: 1);
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        
        self.addSubview(verses_label);
        self.addSubview(title_label);
        self.addSubview(author_label);
    }
    
    init(frame: NSRect, verses: String, from: String, by: String, isDarkMode: Bool, font: String) {
        let font_size_verses = min(0.04 * frame.width, 30 + 0.01 * frame.width);
        super.init(frame: NSRect(origin: frame.origin, size: CGSize(width: frame.width, height: 2.5 * font_size_verses)))
        
        self.is_dark_mode = isDarkMode;
        self.font_name = font
        
        self.verses_str = verses
        self.author_str = by
        self.title_str = from
        
        self.addSubview(verses_label);
        self.addSubview(title_label);
        self.addSubview(author_label);
        
        resize_impl()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func resize_impl() {
        let font_size_verses = min(0.04 * frame.width, 30 + 0.01 * frame.width);
        let font_size_title = min(10+0.01*frame.width, 0.022*frame.width)
        let font_size_author = font_size_title*0.67;
        
        verses_label.frame = CGRect(origin: CGPoint(x: 0, y: font_size_verses),
                                    size: CGSize(width: frame.width, height: font_size_verses*1.5))
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
        
        
        title_label.backgroundColor = .none
        let attrs1: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: NSFont(name: font_name, size: font_size_title) ?? .systemFont(ofSize: font_size_title),
            NSAttributedString.Key.paragraphStyle: paraph,
        ]
        title_label.attributedStringValue = NSAttributedString(string: title_str, attributes: attrs1);
        title_label.isBezeled = false
        title_label.isEditable = false
        title_label.alignment = .center
        title_label.textColor = is_dark_mode ? Constants.verses_text_dark : Constants.verses_text_light;
        title_label.sizeToFit()
        
        
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
        
        
        let title_height = title_label.frame.height;
        let title_width = title_label.frame.width;
        let author_width = author_label.frame.width;
        let total_width = author_width + title_width;
        title_label.frame.origin = CGPoint(x: frame.width/2 - total_width/2 , y: 0)
        let a : CGFloat = frame.width/2 - total_width/2 + title_width;
        let b : CGFloat = title_height * 0.1;
        author_label.frame.origin = CGPoint(x: a, y: b);
    }
    
    func setVerses(verses: String, from: String, by: String) {
        self.verses_str = verses
        self.author_str = by
        self.title_str = from
        
        resize_impl()
    }
    
    override func resize(withOldSuperviewSize oldSize: NSSize) {
        super.resize(withOldSuperviewSize: oldSize)
        resize_impl()
    }
}
