//
//  Person.swift
//  Tab Calculator
//
//  Created by Matthew Gordon on 6/14/21.
//

import Foundation
import SwiftUI

/*
 Basic struct used for making 'Person' Objects, a Person has a name and a Price (of their food)
 associated with them, wrapping this data in an object makes storing a full party of people in a
 collection much easier
 */
struct Person: Codable, Hashable, Identifiable, View {
    /* Setting the View of a Person to it's toString method so it conforms to View */
    var body: some View {
        Text(self.toString())
    }
    
    /* Conforming it to hashable using this generic id, this allows a Persons to be stored in a collection */
    var id = UUID()
    
    /* String variables for the Person's Data */
    var name: String
    var price: String
    
    /* Constructor for a Person, just takes two Strings */
    init(_ name: String, _ price: String) {
        self.name = name
        self.price = price
    }
    
    /* Name getter */
    func getName() -> String {
        return self.name
    }
    
    /* Price getter */
    func getPrice() -> String {
        return self.price
    }
    
    /* Converts a Person into a formatted String representing that Person's Data */
    func toString() -> String {
        /* Return statement for the formatted String (Example: "Joe: $10") */
        return self.name + ":" + " " + "$" + self.price
    }
    
    
}

