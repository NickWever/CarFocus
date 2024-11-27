//
//  SetUitbreidingen.swift
//  CarFocus
//
//  Created by Nick Wever on 07/10/2024.
//

extension Set where Element: Hashable {
    mutating func toggleMembership(of element: Element) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }
}
