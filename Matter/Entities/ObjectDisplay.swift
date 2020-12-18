//
//  ObjectDisplay.swift
//  Matter
//
//  Created by Ziyi Liew on 19/12/20.
//

import Foundation
import UIKit

class ObjectDisplay {
    var name = String()
    var weight:Double = 0
    var image:UIImage?
    
    init(name: String, weight: Double, image: UIImage) {
        self.name = name
        self.weight = weight
        self.image = image
    }
}
