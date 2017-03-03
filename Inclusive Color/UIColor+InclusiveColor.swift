//
//  UIColor+InclusiveColor.swift
//  Inclusive Color
//
//  Created by Laura Ragone on 3/3/17.
//  Copyright © 2017 Laura Ragone. All rights reserved.
//

import UIKit

typealias RGBA = (red: Int, green: Int, blue: Int, alpha: Int)

extension UIColor {
    
    /// Returns the color simulated to appear as though viewed by an individual afflicted with a specified type of color blindness.
    ///
    /// - Parameter type: The type of colorblindness for which to simulate the color.
    /// - Returns: The color simulated to appear as though viewed by an individual afflicted with a specified type of color blindness.
    func inclusiveColor(for type: InclusiveColor.BlindnessType) -> UIColor {
        let inclusiveColor = InclusiveColor()
        guard let color = rgba() else { fatalError("Attempted to simulate the appearance of an unspecified color.") }

        switch type {
        case .normal:
            return inclusiveColor.rgbToUIColor(rgb: color)
        case .protanopia:
            return inclusiveColor.rgbToUIColor(rgb: inclusiveColor.blindMK(rgb: color, deficiency: .protan))
        case .protanomaly:
            return inclusiveColor.rgbToUIColor(rgb: inclusiveColor.anomylize(rgb: color, adjustedRGB: (inclusiveColor.blindMK(rgb: color, deficiency: .protan))))
        case .deuteranopia:
            return inclusiveColor.rgbToUIColor(rgb: inclusiveColor.blindMK(rgb: color, deficiency: .deutan))
        case .deuteranomaly:
            return inclusiveColor.rgbToUIColor(rgb: inclusiveColor.anomylize(rgb: color, adjustedRGB: (inclusiveColor.blindMK(rgb: color, deficiency: .deutan))))
        case .tritanopia:
            return inclusiveColor.rgbToUIColor(rgb: inclusiveColor.blindMK(rgb: color, deficiency: .tritan))
        case .tritanomaly:
            return inclusiveColor.rgbToUIColor(rgb: inclusiveColor.anomylize(rgb: color, adjustedRGB: (inclusiveColor.blindMK(rgb: color, deficiency: .tritan))))
        case .achromatopsia:
            return inclusiveColor.rgbToUIColor(rgb: inclusiveColor.monochrome(rgb: color))
        case .achromatomaly:
            return inclusiveColor.rgbToUIColor(rgb: inclusiveColor.anomylize(rgb: color, adjustedRGB: (inclusiveColor.monochrome(rgb: color))))
        }
    }
    
    func rgba() -> RGBA? {
        var redLiteral = CGFloat(0.0), greenLiteral = CGFloat(0.0), blueLiteral = CGFloat(0.0), alphaLiteral = CGFloat(0.0)
        
        guard getRed(&redLiteral, green: &greenLiteral, blue: &blueLiteral, alpha: &alphaLiteral) else { assertionFailure("Could not extract RGBA components"); return nil }
        
        return (red: Int(redLiteral * 255), green: Int(greenLiteral * 255), blue: Int(blueLiteral * 255), alpha: Int(alphaLiteral) * 255)
    }
}
