//
//  PrintingDisplay.swift
//  Matter
//
//  Created by Ziyi Liew on 23/12/20.
//

import Foundation
import UIKit

class PrintingDisplay {
    var image:UIImage?
    var item = String()
    var printer = String()
    var diameter:Double = 0
    var weight:Double = 0
    
    init (image: UIImage, item: String, printer: String, diameter: Double, weight: Double) {
        self.image = image
        self.item = item
        self.printer = printer
        self.diameter = diameter
        self.weight = weight
    }
}