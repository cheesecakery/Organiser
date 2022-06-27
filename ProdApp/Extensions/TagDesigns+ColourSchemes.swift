//
//  TagDesigns.swift
//  ProdApp
//
//  Created by Permindar LvL on 24/08/2021.
//

import Foundation
import UIKit

//For tags - pretty self explanatory
struct Tag {
    var activityType: String
    var background: UIColor?
    var highlight: UIColor?
}

var tags = [Tag]()

struct colourScheme {
    var background: String
    var highlight: String
}

let defaultColour = colourScheme(background: "Default1", highlight: "Default2")
let blue = colourScheme(background: "BlueA", highlight: "BlueB")
let candyfloss = colourScheme(background: "CandyflossA", highlight: "CandyflossB")
let green = colourScheme(background: "GreenA", highlight: "GreenB")
let lightBlue = colourScheme(background: "LightBlueA", highlight: "LightBlueB")
let navy = colourScheme(background: "NavyA", highlight: "NavyB")
let orange = colourScheme(background: "OrangeA", highlight: "OrangeB")
let red = colourScheme(background: "RedA", highlight: "RedB")
let turquoise = colourScheme(background: "TurquoiseA", highlight: "TurquoiseB")
let watermelon = colourScheme(background: "WatermelonA", highlight: "WatermelonB")
let beach = colourScheme(background: "BeachA", highlight: "BeachB")
let sponge = colourScheme(background: "SpongeA", highlight: "SpongeB")

let colours = [defaultColour, blue, candyfloss, green, lightBlue, navy, orange, red, turquoise, watermelon, beach]

var icons = [String]()
