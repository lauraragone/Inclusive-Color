//
//  InclusiveColor.swift
//  Inclusive Color
//
//  Created by Laura Ragone on 3/3/17.
//  Copyright © 2017 Laura Ragone. All rights reserved.
//

import Foundation
import UIKit

final class InclusiveColor {
    
    // MARK: - Nested Types
    
    /// The color deficiency resulting from the absence or abnormality of a single photopigment.
    ///
    /// - protan: A red-green color limitation specifically hindering the perception of red hues.
    /// - deutan: A red-green color limitation specifically hindering the perception of green hues.
    /// - tritan: A blue-yellow color limitation.
    enum Deficiency {
        case protan
        case deutan
        case tritan
        
        /// A tuple containing some sort of gibberish.
        typealias DeficiencyData = (cpu: Double, cpv: Double, am: Double, ayi: Double)
        
        /// The values corresponding to that gibberish.
        var values: DeficiencyData {
            switch self {
            case .protan:
                return DeficiencyData(cpu: 0.735, cpv: 0.265, am: 1.273463, ayi: -0.073894)
            case .deutan:
                return DeficiencyData(cpu: 1.14, cpv: -0.14, am: 0.968437, ayi: 0.003331)
            case .tritan:
                return DeficiencyData(cpu: 0.171, cpv: -0.003, am: 0.062921, ayi: 0.292119)
            }
        }
    }
    
    /// The form of colorblindness.
    ///
    /// - normal: No color limitations.
    /// - protanopia: A red-green color deficiency specifically hindering the perception of red hues.
    /// - protanomaly: A red-green color abnormality specifically hindering the perception of red hues.
    /// - deuteranopia: A red-green color deficiency specifically hindering the perception of green hues.
    /// - deuteranomaly: A red-green color deficiency specifically hindering the perception of green hues.
    /// - tritanopia: A blue-yellow color deficiency.
    /// - tritanomaly: A blue-yellow color abnormality.
    /// - achromatopsia: A deficiency affecting all hues.
    /// - achromatomaly: An abnormality affecting all hues.
    enum BlindnessType {
        case normal
        case protanopia
        case protanomaly
        case deuteranopia
        case deuteranomaly
        case tritanopia
        case tritanomaly
        case achromatopsia
        case achromatomaly
    }
    
    // MARK: - Properties
    
    private lazy var gammaPowerLookupTable: [Double] = {
        var array = [Double]()
        for index in 0..<256 {
            array.append(pow((Double(index) / 255.0), 2.2))
        }
        return array
    }()
    
    // MARK: - InclusiveColor
    
    func rgbToUIColor(rgb: RGBA) -> UIColor {
        let red = CGFloat(rgb.red) / 255.0
        let green = CGFloat(rgb.green) / 255.0
        let blue = CGFloat(rgb.blue) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func blindMK(rgb: RGBA, deficiency: Deficiency) -> RGBA {
        let wx = 0.312713
        let wy = 0.329016
        let wz = 0.358271
        
        let b = rgb.blue
        let g = rgb.green
        let r = rgb.red
        
        let cr = gammaPowerLookupTable[r]
        let cg = gammaPowerLookupTable[g]
        let cb = gammaPowerLookupTable[b]
        // rgb -> xyz
        let cx = (0.430574 * cr + 0.341550 * cg + 0.178325 * cb)
        let cy = (0.222015 * cr + 0.706655 * cg + 0.071330 * cb)
        let cz = (0.020183 * cr + 0.129553 * cg + 0.939180 * cb)
        
        let sumXYZ = cx + cy + cz
        
        let cu: Double
        let cv: Double
        if (sumXYZ != 0) {
            cu = cx / sumXYZ
            cv = cy / sumXYZ
        } else {
            cu = 0
            cv = 0
        }
        
        let nx = wx * cy / wy
        let nz = wz * cy / wy
        let clm: Double
        let dy = 0.0
        
        if (cu < deficiency.values.cpu) {
            clm = (deficiency.values.cpv - cv) / (deficiency.values.cpu - cu)
        } else {
            clm = (cv - deficiency.values.cpv) / (cu - deficiency.values.cpu)
        }
        
        let clyi = cv - cu * clm
        let du = (deficiency.values.ayi - clyi) / (clm - deficiency.values.am)
        let dv = (clm * du) + clyi
        
        let sx = du * cy / dv
        let sy = cy
        let sz = (1 - (du + dv)) * cy / dv
        // xzy->rgb
        var sr: Double =  (3.063218 * sx - 1.393325 * sy - 0.475802 * sz)
        var sg: Double = (-0.969243 * sx + 1.875966 * sy + 0.041555 * sz)
        var sb: Double =  (0.067871 * sx - 0.228834 * sy + 1.069251 * sz)
        
        let dx = nx - sx
        let dz = nz - sz
        // xzy->rgb
        let dr =  (3.063218 * dx - 1.393325 * dy - 0.475802 * dz)
        let dg = (-0.969243 * dx + 1.875966 * dy + 0.041555 * dz)
        let db =  (0.067871 * dx - 0.228834 * dy + 1.069251 * dz)
        
        let adjr: Double = dr > 0 ? ((sr < 0 ? 0 : 1) - sr) / dr : 0.0
        let adjg: Double = dg > 0 ? ((sg < 0 ? 0 : 1) - sg) / dg : 0.0
        let adjb: Double = db > 0 ? ((sb < 0 ? 0 : 1) - sb) / db : 0.0
        
        let adjust = max(((adjr > 1 || adjr < 0) ? 0 : adjr), ((adjg > 1 || adjg < 0) ? 0 : adjg), ((adjb > 1 || adjb < 0) ? 0 : adjb))
        
        sr = sr + (adjust * dr)
        sg = sg + (adjust * dg)
        sb = sb + (adjust * db)
        
        return (red: Int(inversePow(sr)), green: Int(inversePow(sg)), Int(inversePow(sb)), alpha: rgb.alpha)
    }
    
    func anomylize(rgb: RGBA, adjustedRGB: RGBA) -> RGBA {
        let v = 1.75
        let d = v * 1 + 1
        
        return (red: Int((v * Double(adjustedRGB.red) + Double(rgb.red) * 1) / d),
                green: Int((v * Double(adjustedRGB.green) + Double(rgb.green) * 1) / d),
                blue: Int((v * Double(adjustedRGB.blue) + Double(rgb.blue) * 1) / d),
                alpha: rgb.alpha)
    }
    
    func monochrome(rgb: RGBA) -> RGBA {
        let z = Int(round(Double(rgb.red) * 0.299 + Double(rgb.green) * 0.587 + Double(rgb.blue) * 0.114))
        return (red: z, green: z, blue: z, alpha: rgb.alpha)
    }
}

private extension InclusiveColor {
    
    // TODO: Create RGBAToXYZA(rgba: RGBA) -> XYZA function

    // TODO: Create XYZAToRGBA(xyza: XYZA) -> RGBA function
    
    func inversePow(_ num: Double) -> Double {
        return (255 * (num <= 0 ? 0 : num >= 1 ? 1 : pow(num, 1 / 2.2)))
    }
    
}
 
