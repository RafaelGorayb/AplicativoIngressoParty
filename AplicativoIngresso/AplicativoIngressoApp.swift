//
//  AplicativoIngressoApp.swift
//  AplicativoIngresso
//
//  Created by Rafael Gorayb Correa on 16/03/23.
//

import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import StripeCore

@main
struct AplicativoIngressoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            let user = UserViewModel()
            let evento = EventoViewModel()
            
            ContentView()
                .environmentObject(user)
                .environmentObject(evento)
                .preferredColorScheme(.light)
                .onOpenURL { incomingURL in
                    let stripeHandled = StripeAPI.handleURLCallback(with: incomingURL)
                    if (!stripeHandled) {
                        // This was not a Stripe url – handle the URL normally as you would
                    }
                }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        StripeAPI.defaultPublishableKey = "pk_test_51NST8vERPZEdqIxue9hB2yEYJkrELspnY3aoSbV3XVYo5Mju4zQfHNZ9ONWpYXgSDKK2x4A55x5ZW5gAAua3Yo0a00OvPrbjo4"
        FirebaseApp.configure()
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
}
