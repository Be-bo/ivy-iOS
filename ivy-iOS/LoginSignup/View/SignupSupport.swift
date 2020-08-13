//
//  SignupSupport.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-13.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

// Gradient
struct Gradient: View {
    var body: some View {
        LinearGradient(
            gradient: .init(colors: [AssetManager.ivyGreen, Color.white, Color.white, Color.white]),
            startPoint: .bottom,
            endPoint: .top)
        .edgesIgnoringSafeArea(.all)
    }
}

// Ivy Logo
struct Logo: View {
    var body: some View {
        Image("LogoGreen")
        .resizable()
        .frame(width: 200, height: 200, alignment: .center)
    }
}
