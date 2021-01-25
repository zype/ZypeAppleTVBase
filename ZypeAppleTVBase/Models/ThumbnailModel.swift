//
//  ThumbnailModel.swift
//  Zype
//
//  Created by Ilya Sorokin on 10/21/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

public enum LayoutOrientation: String {
    
    case landscape = "landscape", poster = "poster", square = "square"
    
    public init(rawValue: String) {
        switch rawValue {
        case "landscape": self = .landscape
        case "poster": self = .poster
        case "square": self = .square
        default: self = .landscape
        }
    }
}

open class ThumbnailModel: NSObject {
    
    public let height: Int
    public let width: Int
    public let imageURL: String
    public let name: String
    public let layout: LayoutOrientation?
    
    init(height: Int, width: Int, url:String, name: String, layout: LayoutOrientation?) {
        self.height = height
        self.width = width
        self.imageURL = url
        self.name = name
        self.layout = layout
        super.init()
    }

}
