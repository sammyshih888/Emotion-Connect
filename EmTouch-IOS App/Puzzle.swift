//
//  Puzzle.swift
//  QuizGame (iOS)
//
//  Created by Balaji on 14/02/22.
//

import SwiftUI

// MARK: Puzzle Model and sample Puzzles
struct Puzzle: Identifiable{
    var id: String = UUID().uuidString
    var imageName: String
    var text: String
    var media: String
    var ext: String
    var tag: String

    
    // MARK: 
    var imgOptions: [String] = []
}



var puzzles: [Puzzle] = [
    Puzzle(imageName: "happy", text:"開心", media: "happy" , ext:"wav" , tag: "H"),
    Puzzle(imageName: "sad",  text:"難過", media: "cry" , ext:"mp3", tag: "S"),
    Puzzle(imageName: "angry",  text:"生氣", media: "angry" , ext:"wav", tag: "A"),
    Puzzle(imageName: "surprise",  text:"驚訝", media: "scream", ext:"wav" , tag: "U")
]

var emtypes: [String] = ["A","H","S","U"]
