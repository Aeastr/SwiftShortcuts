//
//  ColorExtensions.swift
//  SwiftShortcuts
//

import SwiftUI

// MARK: - Adaptive Color

extension Color {
    init(light: Color, dark: Color) {
#if canImport(UIKit)
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
#else
        self.init(NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(dark)
                : NSColor(light)
        })
#endif
    }
}

// MARK: - Shortcut Gradient Colors

/// Contains the gradient colors for each shortcut color theme
struct ShortcutGradientColors {
    let lightTop: Color
    let lightBottom: Color
    let darkTop: Color
    let darkBottom: Color
}

// MARK: - Shortcut Color Definitions

/// Native SwiftUI color definitions for Apple Shortcuts icon colors
/// RGB values computed from original hex values using: int(hex, 16) / 255.0
enum ShortcutColorPalette {
    // Red: #eb7677 -> #e16667 (light), #bc5f5f -> #b45252 (dark)
    static let red = ShortcutGradientColors(
        lightTop: Color(red: 0.9215686275, green: 0.4627450980, blue: 0.4666666667),
        lightBottom: Color(red: 0.8823529412, green: 0.4000000000, blue: 0.4039215686),
        darkTop: Color(red: 0.7372549020, green: 0.3725490196, blue: 0.3725490196),
        darkBottom: Color(red: 0.7058823529, green: 0.3215686275, blue: 0.3215686275)
    )

    // Dark Orange: #f09979 -> #ed8566 (light), #c07a61 -> #be6a52 (dark)
    static let darkOrange = ShortcutGradientColors(
        lightTop: Color(red: 0.9411764706, green: 0.6000000000, blue: 0.4745098039),
        lightBottom: Color(red: 0.9294117647, green: 0.5215686275, blue: 0.4000000000),
        darkTop: Color(red: 0.7529411765, green: 0.4784313725, blue: 0.3803921569),
        darkBottom: Color(red: 0.7450980392, green: 0.4156862745, blue: 0.3215686275)
    )

    // Orange: #f4ba66 -> #eba755 (light), #c39552 -> #bc8644 (dark)
    static let orange = ShortcutGradientColors(
        lightTop: Color(red: 0.9568627451, green: 0.7294117647, blue: 0.4000000000),
        lightBottom: Color(red: 0.9215686275, green: 0.6549019608, blue: 0.3333333333),
        darkTop: Color(red: 0.7647058824, green: 0.5843137255, blue: 0.3215686275),
        darkBottom: Color(red: 0.7372549020, green: 0.5254901961, blue: 0.2666666667)
    )

    // Yellow: #f6d947 -> #e7c63b (light), #c5ae39 -> #b99e2f (dark)
    static let yellow = ShortcutGradientColors(
        lightTop: Color(red: 0.9647058824, green: 0.8509803922, blue: 0.2784313725),
        lightBottom: Color(red: 0.9058823529, green: 0.7764705882, blue: 0.2313725490),
        darkTop: Color(red: 0.7725490196, green: 0.6823529412, blue: 0.2235294118),
        darkBottom: Color(red: 0.7254901961, green: 0.6196078431, blue: 0.1843137255)
    )

    // Green: #6fd670 -> #60c35f (light), #599e58 -> #4d9c4c (dark)
    static let green = ShortcutGradientColors(
        lightTop: Color(red: 0.4352941176, green: 0.8392156863, blue: 0.4392156863),
        lightBottom: Color(red: 0.3764705882, green: 0.7647058824, blue: 0.3725490196),
        darkTop: Color(red: 0.3490196078, green: 0.6196078431, blue: 0.3450980392),
        darkBottom: Color(red: 0.3019607843, green: 0.6117647059, blue: 0.2980392157)
    )

    // Teal: #5be0c1 -> #3ccaac (light), #49b39a -> #30a289 (dark)
    static let teal = ShortcutGradientColors(
        lightTop: Color(red: 0.3568627451, green: 0.8784313725, blue: 0.7568627451),
        lightBottom: Color(red: 0.2352941176, green: 0.7921568627, blue: 0.6745098039),
        darkTop: Color(red: 0.2862745098, green: 0.7019607843, blue: 0.6039215686),
        darkBottom: Color(red: 0.1882352941, green: 0.6352941176, blue: 0.5372549020)
    )

    // Light Blue: #95defb -> #80c9ed (light), #78b2c7 -> #66a1bd (dark)
    static let lightBlue = ShortcutGradientColors(
        lightTop: Color(red: 0.5843137255, green: 0.8705882353, blue: 0.9843137255),
        lightBottom: Color(red: 0.5019607843, green: 0.7882352941, blue: 0.9294117647),
        darkTop: Color(red: 0.4705882353, green: 0.6980392157, blue: 0.7803921569),
        darkBottom: Color(red: 0.4000000000, green: 0.6313725490, blue: 0.7411764706)
    )

    // Blue: #509ef8 -> #438df7 (light), #407ec6 -> #366fc5 (dark)
    static let blue = ShortcutGradientColors(
        lightTop: Color(red: 0.3137254902, green: 0.6196078431, blue: 0.9725490196),
        lightBottom: Color(red: 0.2627450980, green: 0.5529411765, blue: 0.9686274510),
        darkTop: Color(red: 0.2509803922, green: 0.4941176471, blue: 0.7764705882),
        darkBottom: Color(red: 0.2117647059, green: 0.4352941176, blue: 0.7725490196)
    )

    // Dark Blue: #627bd7 -> #4d66c3 (light), #4f629c -> #3e529c (dark)
    static let darkBlue = ShortcutGradientColors(
        lightTop: Color(red: 0.3843137255, green: 0.4823529412, blue: 0.8431372549),
        lightBottom: Color(red: 0.3019607843, green: 0.4000000000, blue: 0.7647058824),
        darkTop: Color(red: 0.3098039216, green: 0.3843137255, blue: 0.6117647059),
        darkBottom: Color(red: 0.2431372549, green: 0.3215686275, blue: 0.6117647059)
    )

    // Purple: #8c63c8 -> #774eb3 (light), #704f9f -> #5f3e90 (dark)
    static let purple = ShortcutGradientColors(
        lightTop: Color(red: 0.5490196078, green: 0.3882352941, blue: 0.7843137255),
        lightBottom: Color(red: 0.4666666667, green: 0.3058823529, blue: 0.7019607843),
        darkTop: Color(red: 0.4392156863, green: 0.3098039216, blue: 0.6235294118),
        darkBottom: Color(red: 0.3725490196, green: 0.2431372549, blue: 0.5647058824)
    )

    // Light Purple: #bf87f0 -> #aa72da (light), #996bbf -> #885bae (dark)
    static let lightPurple = ShortcutGradientColors(
        lightTop: Color(red: 0.7490196078, green: 0.5294117647, blue: 0.9411764706),
        lightBottom: Color(red: 0.6666666667, green: 0.4470588235, blue: 0.8549019608),
        darkTop: Color(red: 0.6000000000, green: 0.4196078431, blue: 0.7490196078),
        darkBottom: Color(red: 0.5333333333, green: 0.3568627451, blue: 0.6823529412)
    )

    // Pink: #ee96de -> #e184cb (light), #be78ae -> #b369a2 (dark)
    static let pink = ShortcutGradientColors(
        lightTop: Color(red: 0.9333333333, green: 0.5882352941, blue: 0.8705882353),
        lightBottom: Color(red: 0.8823529412, green: 0.5176470588, blue: 0.7960784314),
        darkTop: Color(red: 0.7450980392, green: 0.4705882353, blue: 0.6823529412),
        darkBottom: Color(red: 0.7019607843, green: 0.4117647059, blue: 0.6352941176)
    )

    // Gray: #96a0a9 -> #848d97 (light), #78818a -> #6a7179 (dark)
    static let gray = ShortcutGradientColors(
        lightTop: Color(red: 0.5882352941, green: 0.6274509804, blue: 0.6627450980),
        lightBottom: Color(red: 0.5176470588, green: 0.5529411765, blue: 0.5921568627),
        darkTop: Color(red: 0.4705882353, green: 0.5058823529, blue: 0.5411764706),
        darkBottom: Color(red: 0.4156862745, green: 0.4431372549, blue: 0.4745098039)
    )

    // Green-Gray: #aec3b0 -> #98ad9a (light), #899c8b -> #7a8a7c (dark)
    static let greenGray = ShortcutGradientColors(
        lightTop: Color(red: 0.6823529412, green: 0.7647058824, blue: 0.6901960784),
        lightBottom: Color(red: 0.5960784314, green: 0.6784313725, blue: 0.6039215686),
        darkTop: Color(red: 0.5372549020, green: 0.6117647059, blue: 0.5450980392),
        darkBottom: Color(red: 0.4784313725, green: 0.5411764706, blue: 0.4862745098)
    )

    // Brown: #cdb799 -> #baa487 (light), #a4916e -> #96836c (dark)
    static let brown = ShortcutGradientColors(
        lightTop: Color(red: 0.8039215686, green: 0.7176470588, blue: 0.6000000000),
        lightBottom: Color(red: 0.7294117647, green: 0.6431372549, blue: 0.5294117647),
        darkTop: Color(red: 0.6431372549, green: 0.5686274510, blue: 0.4313725490),
        darkBottom: Color(red: 0.5882352941, green: 0.5137254902, blue: 0.4235294118)
    )
}

// MARK: - Public Gradients

/// Pre-defined gradients matching Apple Shortcuts colors.
/// Use with `.foregroundStyle()`:
/// ```swift
/// ShortcutCard(name: "My Shortcut", systemImage: "star", url: "...")
///     .foregroundStyle(ShortcutGradient.blue)
/// ```
public enum ShortcutGradient {
    public static let red = makeGradient(ShortcutColorPalette.red)
    public static let darkOrange = makeGradient(ShortcutColorPalette.darkOrange)
    public static let orange = makeGradient(ShortcutColorPalette.orange)
    public static let yellow = makeGradient(ShortcutColorPalette.yellow)
    public static let green = makeGradient(ShortcutColorPalette.green)
    public static let teal = makeGradient(ShortcutColorPalette.teal)
    public static let lightBlue = makeGradient(ShortcutColorPalette.lightBlue)
    public static let blue = makeGradient(ShortcutColorPalette.blue)
    public static let darkBlue = makeGradient(ShortcutColorPalette.darkBlue)
    public static let purple = makeGradient(ShortcutColorPalette.purple)
    public static let lightPurple = makeGradient(ShortcutColorPalette.lightPurple)
    public static let pink = makeGradient(ShortcutColorPalette.pink)
    public static let gray = makeGradient(ShortcutColorPalette.gray)
    public static let greenGray = makeGradient(ShortcutColorPalette.greenGray)
    public static let brown = makeGradient(ShortcutColorPalette.brown)

    private static func makeGradient(_ colors: ShortcutGradientColors) -> LinearGradient {
        let topColor = Color(light: colors.lightTop, dark: colors.darkTop)
        let bottomColor = Color(light: colors.lightBottom, dark: colors.darkBottom)
        return LinearGradient(
            colors: [bottomColor, topColor],
            startPoint: .bottom,
            endPoint: .top
        )
    }
}

// MARK: - Internal Color Mapping

/// Maps Apple Shortcuts icon color codes to gradient colors
enum ShortcutColors {
    static let colorMap: [Int64: ShortcutGradientColors] = [
        4282601983: ShortcutColorPalette.red,           // Red
        12365313: ShortcutColorPalette.red,             // Red (alt)
        43634177: ShortcutColorPalette.darkOrange,      // Dark orange
        4251333119: ShortcutColorPalette.darkOrange,    // Dark orange (alt)
        4271458815: ShortcutColorPalette.orange,        // Orange
        23508481: ShortcutColorPalette.orange,          // Orange (alt)
        4274264319: ShortcutColorPalette.yellow,        // Yellow
        20702977: ShortcutColorPalette.yellow,          // Yellow (alt)
        4292093695: ShortcutColorPalette.green,         // Green
        2873601: ShortcutColorPalette.green,            // Green (alt)
        431817727: ShortcutColorPalette.teal,           // Teal
        1440408063: ShortcutColorPalette.lightBlue,     // Light blue
        463140863: ShortcutColorPalette.blue,           // Blue
        946986751: ShortcutColorPalette.darkBlue,       // Dark blue
        2071128575: ShortcutColorPalette.purple,        // Purple
        3679049983: ShortcutColorPalette.lightPurple,   // Light purple
        61591313: ShortcutColorPalette.lightPurple,     // Light purple (alt)
        314141441: ShortcutColorPalette.pink,           // Pink
        3980825855: ShortcutColorPalette.pink,          // Pink (alt)
        255: ShortcutColorPalette.gray,                 // Gray
        1263359489: ShortcutColorPalette.gray,          // Gray (alt)
        3031607807: ShortcutColorPalette.greenGray,     // Green-Gray
        1448498689: ShortcutColorPalette.brown,         // Brown
        2846468607: ShortcutColorPalette.brown,         // Brown (alt)
    ]

    static func gradient(for iconColor: Int64) -> LinearGradient {
        let normalizedColor = abs(iconColor)

        guard let colors = colorMap[normalizedColor] else {
            return LinearGradient(colors: [.gray], startPoint: .bottom, endPoint: .top)
        }

        let topColor = Color(light: colors.lightTop, dark: colors.darkTop)
        let bottomColor = Color(light: colors.lightBottom, dark: colors.darkBottom)

        return LinearGradient(
            colors: [bottomColor, topColor],
            startPoint: .bottom,
            endPoint: .top
        )
    }
}
