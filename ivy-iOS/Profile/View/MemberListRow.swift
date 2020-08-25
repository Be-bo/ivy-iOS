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
    @State var memberIds = [String]()
    @State var titleText = "Members"
    
    var body: some View {
        VStack {
            HStack{
                Text(self.titleText)
                Spacer()
            }
            ScrollView(.horizontal){
                HStack{
                    ForEach(memberIds, id: \.self) { currentId in
                        PersonCircleView(personId: currentId)
                    }
                }
            }
        }
    }
}
