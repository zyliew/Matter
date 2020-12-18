//
//  SpoolDisplay.swift
//  Matter
//
//  Created by Ziyi Liew on 17/12/20.
//

import Foundation
import UIKit


class SpoolDisplay {
    var material = String()
    var diameter:Double = 0
    var count:Int = 0
    var color = String()
    var image:UIImage?
    var brand = String()
    var uids:[String] = []
    
    init(color:String, material: String, diameter: Double, count: Int, image: UIImage, brand: String) {
        self.material = material
        self.diameter = diameter
        self.count = count
        self.color = color
        self.image = image
        self.brand = brand
    }
    
    func addUid(uid: String) {
        uids.append(uid)
    }
}
