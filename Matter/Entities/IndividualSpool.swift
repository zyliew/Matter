//
//  IndividualSpool.swift
//  Matter
//
//  Created by Ziyi Liew on 18/12/20.
//

import Foundation
import UIKit


class IndividualSpool {
    var material = String()
    var diameter:Double = 0
    var color = String()
    var image:UIImage?
    var brand = String()
    var uid = String()
    var weight:Double = 0
    var link = String()
    
    init(material: String, diameter: Double, color: String, image: UIImage, brand: String, uid: String, weight: Double, link: String) {
        self.material = material
        self.diameter = diameter
        self.color = color
        self.image = image
        self.brand = brand
        self.uid = uid
        self.weight = weight
        self.link = link
    }
}
