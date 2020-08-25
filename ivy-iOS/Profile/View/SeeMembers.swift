//
//  SeeMembers.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-24.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import SwiftUI

struct MemberListRow: View {
    var body: some View {
        VStack {
            Text("Members")
            
            ScrollView {
                HStack {
                    ForEach(1...5, id: \.self) {_ in
                        Image("LogoGreen")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    Spacer()
                }
            }
        }
    }
}
