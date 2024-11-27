//
//  DecoderConfigurationError.swift
//  CarFocus
//
//  Created by Nick Wever on 15/10/2024.
//

import Foundation

// Dit zorgt ervoor dat een foutmelding wordt weergegeven als de ManagedObjectContext ontbreekt
enum DecoderConfigurationError: Error {
    case missingManagedObjectContext
}

