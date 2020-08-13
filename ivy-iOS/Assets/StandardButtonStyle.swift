//
//  StandardButtonStyle.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-13.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

struct StandardButtonStyle: ButtonStyle {
    var disabled = false
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Capsule().fill(disabled ? AssetManager.ivyLightGrey : (configuration.isPressed ? Color.white : AssetManager.ivyGreen)))
            .foregroundColor(Color.white)
    }
}
