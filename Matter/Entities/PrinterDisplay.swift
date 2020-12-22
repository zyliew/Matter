//
//  PrinterDisplay.swift
//  Matter
//
//  Created by Ziyi Liew on 23/12/20.
//

import Foundation
import UIKit

class PrinterDisplay {
    var image:UIImage?
    var name = String()
    var diameter:Double = 0
    
    init (image: UIImage, name: String, diameter: Double) {
        self.image = image
        self.name = name
        self.diameter = diameter
    }
}
