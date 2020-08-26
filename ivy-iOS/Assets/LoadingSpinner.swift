//
//  LoadingSpinner.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-18.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

struct LoadingSpinner: View {
    
    @State var animate = false
    
    var body: some View {
        VStack {
            Circle()
                .trim(from: 0, to: 0.8)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: 30, height: 30)
                .rotationEffect(.init(degrees: self.animate ? 360 : 0))
                .animation(Animation.linear(duration: 0.7)
                    .repeatForever(autoreverses: false))
        }
        .onAppear {
            self.animate.toggle()
        }
    }
}

struct LoadingSpinner_Previews: PreviewProvider {
    static var previews: some View {
        LoadingSpinner()
    }
}
