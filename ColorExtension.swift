//
//  ColorExtension.swift
//  AmadooWidget
//
//  위젯에서 사용하는 SwiftUI Color 확장
//

import SwiftUI

extension Color {
    /// 16진수 문자열로부터 Color 생성
    /// - Parameter hex: 16진수 색상 문자열 (예: "#E6DFF1" 또는 "E6DFF1")
    /// - Returns: SwiftUI Color
    static func fromHex(_ hex: String) -> Color {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }

        guard hexString.count == 6 else { return Color.gray }

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0

        return Color(red: red, green: green, blue: blue)
    }
}
