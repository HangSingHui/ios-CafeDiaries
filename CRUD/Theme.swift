//
//  Theme.swift
//  CRUD
//
//  Created by Sing Hui Hang on 10/10/25.
//

import UIKit

struct Theme {
    // Primary Coffee Colors
    static let coffeeBrown = UIColor(red: 101/255, green: 67/255, blue: 33/255, alpha: 1.0)
    static let lightCoffee = UIColor(red: 141/255, green: 110/255, blue: 75/255, alpha: 1.0)
    static let cream = UIColor(red: 237/255, green: 224/255, blue: 212/255, alpha: 1.0)
    static let espresso = UIColor(red: 59/255, green: 47/255, blue: 47/255, alpha: 1.0)
    
    // Accent Colors
    static let warmOrange = UIColor(red: 211/255, green: 126/255, blue: 68/255, alpha: 1.0)
    static let caramel = UIColor(red: 198/255, green: 134/255, blue: 66/255, alpha: 1.0)
    
    // System-adaptive colors
    static let background = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 28/255, green: 25/255, blue: 23/255, alpha: 1.0)
            : UIColor.systemGroupedBackground
    }
    
    static let cardBackground = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 44/255, green: 39/255, blue: 36/255, alpha: 1.0)
            : UIColor.white
    }
    
    static let primaryText = UIColor.label
    static let secondaryText = UIColor.secondaryLabel
    
    // Star rating color
    static let starYellow = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1.0)
    
    // Apply theme to navigation bar
    static func applyNavigationBarTheme() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() // fine
        appearance.backgroundColor = Theme.coffeeBrown
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 34)
        ]

        UINavigationBar.appearance().prefersLargeTitles = true

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = Theme.cream

    }
    
    // Apply theme to tab bar (if you add one later)
    static func applyTabBarTheme() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = cardBackground
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = coffeeBrown
    }
}
