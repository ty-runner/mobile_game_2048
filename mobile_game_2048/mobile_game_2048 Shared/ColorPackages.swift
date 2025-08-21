//
//  ColorPackages.swift
//  Cleaned & annotated on 2025-08-16 20:11 UTC
//
//  Notes:
//  - This file has been auto-annotated with documentation comments.
//  - Risky constructs (force unwraps, \1
//try! , continuations) are flagged with TODOs.
//  - No public APIs were intentionally changed.
//
import UIKit

let colorPackages: [String: [Int: UIColor]] = [
    "classic": [
        2:    UIColor(red: 0.93, green: 0.92, blue: 0.91, alpha: 1.0), // #EDEBE8 porcelain
        4:    UIColor(red: 0.90, green: 0.90, blue: 0.94, alpha: 1.0), // #E6E6F0 cool mist
        8:    UIColor(red: 0.81, green: 0.89, blue: 0.84, alpha: 1.0), // #CFE3D6 pale sage
        16:   UIColor(red: 0.75, green: 0.84, blue: 0.90, alpha: 1.0), // #BFD6E6 misty blue
        32:   UIColor(red: 0.80, green: 0.75, blue: 0.89, alpha: 1.0), // #CDBFE2 soft lavender
        64:   UIColor(red: 0.73, green: 0.76, blue: 0.85, alpha: 1.0), // #B9C1D9 periwinkle gray
        128:  UIColor(red: 0.69, green: 0.81, blue: 0.75, alpha: 1.0), // #AFCFBF eucalyptus
        256:  UIColor(red: 0.66, green: 0.72, blue: 0.78, alpha: 1.0), // #A8B7C7 blue-gray
        512:  UIColor(red: 0.62, green: 0.67, blue: 0.76, alpha: 1.0), // #9DAAC2 slate
        1024: UIColor(red: 0.56, green: 0.61, blue: 0.71, alpha: 1.0), // #8F9BB5 dusty indigo
        2048: UIColor(red: 0.49, green: 0.54, blue: 0.65, alpha: 1.0)  // #7E8AA6 smoky periwinkle
    ],
    "abstract": [
        2:    UIColor(red: 0.02, green: 0.04, blue: 0.08, alpha: 1),
        4:    UIColor(red: 0.05, green: 0.21, blue: 0.42, alpha: 1),
        8:    UIColor(red: 0.07, green: 0.18, blue: 0.26, alpha: 1),
        16:   UIColor(red: 0.13, green: 0.41, blue: 0.63, alpha: 1),
        32:   UIColor(red: 0.07, green: 0.28, blue: 0.42, alpha: 1),
        64:   UIColor(red: 0.04, green: 0.15, blue: 0.32, alpha: 1),
        128:  UIColor(red: 0.04, green: 0.12, blue: 0.22, alpha: 1),
        256:  UIColor(red: 0.00, green: 0.01, blue: 0.03, alpha: 1),
        1024: UIColor(red: 0.09, green: 0.30, blue: 0.53, alpha: 1),
        2048: UIColor(red: 0.07, green: 0.23, blue: 0.35, alpha: 1),
    ],
    "retro": [  // 8-bit inspired, distinct from vaporwave
        2:    UIColor(red: 0.0, green: 0.0, blue: 0.8, alpha: 1),     // bright blue
        4:    UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1),     // bright red
        8:    UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1),     // bright green
        16:   UIColor(red: 0.8, green: 0.8, blue: 0.0, alpha: 1),     // bright yellow
        32:   UIColor(red: 0.8, green: 0.0, blue: 0.8, alpha: 1),     // bright magenta
        64:   UIColor(red: 0.0, green: 0.8, blue: 0.8, alpha: 1),     // bright cyan
        128:  UIColor(red: 0.6, green: 0.4, blue: 0.0, alpha: 1),     // dark orange
        256:  UIColor(red: 0.4, green: 0.2, blue: 0.0, alpha: 1),     // brown
        512:  UIColor(red: 0.6, green: 0.0, blue: 0.0, alpha: 1),     // dark red
        1024: UIColor(red: 0.0, green: 0.4, blue: 0.6, alpha: 1),     // dark teal
        2048: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1),     // dark gray
    ],
    "oceanic": [
        2:    UIColor(red: 0.06, green: 0.20, blue: 0.34, alpha: 1),  // deep navy blue
        4:    UIColor(red: 0.10, green: 0.35, blue: 0.48, alpha: 1),  // deep teal
        8:    UIColor(red: 0.18, green: 0.55, blue: 0.59, alpha: 1),  // turquoise
        16:   UIColor(red: 0.34, green: 0.70, blue: 0.73, alpha: 1),  // aqua
        32:   UIColor(red: 0.93, green: 0.60, blue: 0.32, alpha: 1),  // coral orange
        64:   UIColor(red: 0.85, green: 0.45, blue: 0.23, alpha: 1),  // deeper coral
        128:  UIColor(red: 0.94, green: 0.80, blue: 0.52, alpha: 1),  // sandy gold
        256:  UIColor(red: 0.74, green: 0.65, blue: 0.38, alpha: 1),  // muted sand
        512:  UIColor(red: 0.54, green: 0.76, blue: 0.72, alpha: 1),  // seafoam
        1024: UIColor(red: 0.38, green: 0.59, blue: 0.66, alpha: 1),  // muted teal
        2048: UIColor(red: 0.20, green: 0.38, blue: 0.46, alpha: 1)   // abyss blue
    ],
    "vaporwave": [
        2:    UIColor(red: 0.73, green: 0.40, blue: 1.00, alpha: 1),
        4:    UIColor(red: 1.00, green: 0.43, blue: 0.78, alpha: 1),
        8:    UIColor(red: 0.49, green: 0.98, blue: 1.00, alpha: 1),
        16:   UIColor(red: 1.00, green: 0.43, blue: 0.78, alpha: 1),
        32:   UIColor(red: 0.06, green: 1.00, blue: 0.99, alpha: 1),
        64:   UIColor(red: 0.98, green: 0.69, blue: 0.68, alpha: 1),
        128:  UIColor(red: 0.95, green: 0.54, blue: 0.63, alpha: 1),
        256:  UIColor(red: 0.91, green: 0.63, blue: 0.75, alpha: 1),
        512:  UIColor(red: 0.85, green: 0.44, blue: 0.84, alpha: 1),
        1024: UIColor(red: 0.87, green: 0.63, blue: 0.87, alpha: 1),
        2048: UIColor(red: 0.78, green: 0.08, blue: 0.52, alpha: 1),
//    ],
//    "country": [
//        2:    UIColor(red: 0.91, green: 0.58, blue: 0.32, alpha: 1),  // warm pumpkin orange
//        4:    UIColor(red: 0.74, green: 0.39, blue: 0.14, alpha: 1),  // deep burnt sienna
//        8:    UIColor(red: 0.98, green: 0.82, blue: 0.42, alpha: 1),  // goldenrod yellow
//        16:   UIColor(red: 0.55, green: 0.45, blue: 0.25, alpha: 1),  // olive green brown
//        32:   UIColor(red: 0.80, green: 0.31, blue: 0.22, alpha: 1),  // adobe red
//        64:   UIColor(red: 0.40, green: 0.30, blue: 0.18, alpha: 1),  // dark chocolate brown
//        128:  UIColor(red: 0.96, green: 0.70, blue: 0.40, alpha: 1),  // warm sandy beige
//        256:  UIColor(red: 0.68, green: 0.54, blue: 0.33, alpha: 1),  // dry mustard yellow
//        512:  UIColor(red: 0.43, green: 0.56, blue: 0.43, alpha: 1),  // muted sage green
//        1024: UIColor(red: 0.95, green: 0.46, blue: 0.33, alpha: 1),  // terracotta red
//        2048: UIColor(red: 0.75, green: 0.22, blue: 0.14, alpha: 1),  // deep chili pepper red
    ]
]

let indexToTheme: [Int: String] = [
    0: "classic",
    1: "abstract",
    2: "retro",
    3: "oceanic",
    4: "vaporwave"
]

let defaultColorPackage = "classic"
var selectedColorKey = "classic"
