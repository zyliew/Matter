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
    var uid = String()
    
    init (image: UIImage, name: String, diameter: Double, uid: String) {
        self.image = image
        self.name = name
        self.diameter = diameter
        self.uid = uid
    }
}
