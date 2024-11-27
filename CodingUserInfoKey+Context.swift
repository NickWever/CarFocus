//
//  CodingUserInfoKey+Context.swift
//  CarFocus
//
//  Created by Nick Wever on 15/10/2024.
//

import Foundation

// Extensie om eenvoudig een context toe te voegen aan de decoder
extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")
}
