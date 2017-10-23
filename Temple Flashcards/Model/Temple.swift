//
//  Temple.swift
//  Temple Flashcards
//
//  Created by Gavin Nitta on 10/16/17.
//  Copyright © 2017 Gavin Nitta. All rights reserved.
//

import Foundation

class Temple {
    
    // Mark: - Properties
    var filename: String = ""
    var name: String = ""
    
    // Mark: - Initialization
    init() {
        // This is going to be blank
    }
    
    init(filename: String, name: String) {
        self.filename = filename
        self.name =  name
    }
    
}
