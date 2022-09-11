//
//  configSheet.swift
//  jizhi_saver
//
//  Created by 谢俊琨 on 2021/4/15.
//

import Foundation
import AppKit

class configSheet : NSWindow {
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        self.contentView?.addSubview(NSButton(title: "Font", target: self, action: #selector(self.select_font)))
    }
    
    @objc func select_font() {
        
    }
}
