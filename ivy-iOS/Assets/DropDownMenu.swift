//
//  DropDownMenu.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-13.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

struct DropDownMenu: View {
    @State var expand = false
    @State var selected: String? = nil
    
    // Provide these arguments
    var list: [String]
    var hint: String = "Expand"
    var background: Color? = nil
    var expandedHeight: CGFloat = 200
    
    
    var body: some View {
        VStack {
            HStack {
                Text(self.selected ?? hint)
                    .fontWeight(.bold)
                Image (systemName: expand ? "chevron.up" : "chevron.down")
                    .resizable()
                    .frame(width: 13, height: 6)
            }
            .onTapGesture {
                self.expand.toggle()
            }
            
            if expand {
                ScrollView {
                    ForEach(self.list, id: \.self) { item in
                        Button(action: {
                            self.expand.toggle()
                            self.selected = item
                        }) {
                            Text(item).padding()
                        }.foregroundColor(.black)
                    }
                }
            .frame(height: expandedHeight)
            }
            
        }
        .padding()
        .background(background)
        .cornerRadius(15)
        .animation(.spring())
        
    }
}

struct DropDownMenu_Previews: PreviewProvider {
    static var previews: some View {
        DropDownMenu(
            list: (1...100).map{"Item \($0)"},
            hint: "Choose a Number",
            background: Color.gray,
            expandedHeight: 200
        )
    }
}
