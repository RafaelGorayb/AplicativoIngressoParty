//
//  NavigationModel.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 23/07/23.
//

import Foundation
import SwiftUI

class NavigationModel: ObservableObject {
    @Published var navigationPath = NavigationPath()
    
    func navigateTo2() {
        navigationPath.append(2)
    }
    
    func navigateTo3() {
        navigationPath.append("1")
    }
    
    func navigateBack() {
        navigationPath.removeLast()
    }
    
    func navigateToRoot() {
        navigationPath = NavigationPath()
    }
}
