//
//  Color Extension.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI

//allow swift to use hex codes
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // three character hex
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: //six character hex
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: //eight character hex
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
    
    var hexString: String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let ri = Int(r*255), gi = Int(g*255), bi = Int(b*255)
        return String(format:"#%02X%02X%02X", ri, gi, bi)
    }
    
    static func isHexDark(_ hex: String) -> Bool {
            // Strip the `#` if it exists
            var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

            var rgb: UInt64 = 0
            Scanner(string: hexSanitized).scanHexInt64(&rgb)

            let r, g, b: Double
            if hexSanitized.count == 6 {
                r = Double((rgb >> 16) & 0xFF) / 255.0
                g = Double((rgb >> 8) & 0xFF) / 255.0
                b = Double(rgb & 0xFF) / 255.0
            } else {
                // fallback gray if parsing fails
                r = 0.5; g = 0.5; b = 0.5
            }

            // Perceived brightness (standard formula)
            let brightness = (r * 299 + g * 587 + b * 114) / 1000
            return brightness < 0.5 // lower = darker
        }
    
    static func blend(_ color1: Color, _ color2: Color, ratio: CGFloat) -> Color {
        let uiColor1 = UIColor(color1)
        let uiColor2 = UIColor(color2)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return Color(
            red: Double(r1 + (r2 - r1) * ratio),
            green: Double(g1 + (g2 - g1) * ratio),
            blue: Double(b1 + (b2 - b1) * ratio),
            opacity: Double(a1 + (a2 - a1) * ratio)
        )
    }
    
    func adjusted(by amount: Double) -> Color {
        // Convert to UIColor to modify brightness/saturation
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // adjust brightness (or saturation)
        let newBrightness = max(min(brightness + CGFloat(amount), 1.0), 0.0)
        return Color(hue: hue, saturation: saturation, brightness: newBrightness)
    }
    
    func toHex() -> String? {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255)
        return String(format: "#%06x", rgb)
    }

    func generateColors(from baseColor: Color, count: Int) -> [Color] {
        let uiColor = UIColor(baseColor)
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0

        guard uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return Array(repeating: baseColor, count: count)
        }

        var colors: [Color] = []

        for i in 0..<count {
            // Fix: Avoid division by zero when count is 1
            let fraction = count > 1 ? CGFloat(i) / CGFloat(count - 1) : 0.5

            // Brightness from dark to light, avoiding too dark or too neon
            let newBrightness = 0.25 + 0.7 * fraction   // 0.25 = dark, 0.95 = light

            // Saturation: darker = richer, lighter = softer/pastel
            let newSaturation = 0.4 + 0.6 * (1 - fraction)  // reduces saturation for light colors

            colors.append(Color(hue: Double(hue), saturation: Double(min(max(newSaturation, 0), 1)), brightness: Double(min(max(newBrightness, 0), 1))))
        }
        return colors
    }
}

extension DateFormatter {
    static var monthYear: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"
        return df
    }
    
    
}

extension String {
    var capitalizedWords: String {
        self
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }
    func width(usingFont font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return (self as NSString).size(withAttributes: attributes).width
    }
}

