//
//  StandardButton.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-10.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

struct StandardButton<CustomView: View>: View{ //any view has to be passed in that conforms to View
    let action: () -> Void
    let content: CustomView
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> CustomView) { //action will escape the scope
        self.action = action
        self.content = content() //need to immediately call to build it
    }
    
    var body: some View{
        Button(action: action){
            content
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Capsule().fill(AssetManager.ivyGreen))
                .foregroundColor(Color.white)
        }
    }
    
}

struct StandardButton_Previews: PreviewProvider {
    static var previews: some View {
        StandardButton(action: {print("Clicked")}){
            Text("Button")
        }
    }
}
