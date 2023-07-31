//
//  Commands.swift
//  mooApp
//
//  Created by duy on 3/25/16.
//  Copyright © 2016 moosocialloft. All rights reserved.
//

import Foundation

enum Command : String {
    case LIST_PEOPLE = "L: List People";
    case ADD_PERSON = "A: Add Person";
    case DELETE_PERSON = "D: Delete Person";
    case UPDATE_PERSON = "U: Update Person";
    case SEARCH = "S: Search";
    static let ALL = [Command.LIST_PEOPLE, Command.ADD_PERSON,
                      Command.DELETE_PERSON, Command.UPDATE_PERSON, Command.SEARCH];
    static func getFromInput(_ input:String) -> Command? {
        switch (input.lowercased()) {
        case "l":
            return Command.LIST_PEOPLE;
        case "a":
            return Command.ADD_PERSON;
        case "d":
            return Command.DELETE_PERSON;
        case "u":
            return Command.UPDATE_PERSON;
        case "s":
            return Command.SEARCH;
        default:
            return nil;
        }
    }
}
