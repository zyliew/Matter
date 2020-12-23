//
//  CustomString.swift
//  Matter
//
//  Created by Ziyi Liew on 23/12/20.
//

import Foundation

// for input type checking
extension String {
    var isInteger: Bool { return Int(self) != nil }
    var isFloat: Bool { return Float(self) != nil }
    var isDouble: Bool { return Double(self) != nil }
}
