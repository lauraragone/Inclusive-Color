# Inclusive-Color

## Color Blindness Simulation for `UIColor`

This library was demonstrated at the Color Me Surprised! Architecting a Robust Color System in Swift talk presented at try! Swift Tokyo 2017.

A link to the presentation and its associated materials will be provided once available.

*Note*: Cocoapod support to be added prior to the March 4th Hackathon :)

## What it Does

This library provides a `UIColor` function that may be used to simulate the appearance of a color as it would appear to a user experiencing the following color limited visual deficiencies and anormalities:
    
    - protanopia
        - A red-green color deficiency specifically hindering the perception of red hues.
    - protanomaly
        - A red-green color abnormality specifically hindering the perception of red hues.
    - deuteranopia
        - A red-green color deficiency specifically hindering the perception of green hues.
    - deuteranomaly
        - A red-green color deficiency specifically hindering the perception of green hues.
    - tritanopia
        - A blue-yellow color deficiency.
    - tritanomaly
        - A blue-yellow color abnormality.
    - achromatopsia
        - A deficiency affecting all hues.
    - achromatomaly
        - An abnormality affecting all hues.
    - normal
        - No color limitations.
        
## How to Use

Simply call `func inclusiveColor(for type: InclusiveColor.BlindnessType)` upon a `UIColor` instance to display the color as it may appear to an affected individual.

*Example:*

``` let color = UIColor.red.inclusiveColor(for: .deuteranopia)```
