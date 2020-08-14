//
//  DropDownMenu.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-13.
//  Copyright © 2020 ivy. All rights reserved.
//
//  Reference:
//  https://medium.com/@anthonycodesofficial/swiftui-tutorial-how-to-create-a-floating-drop-down-menu-cc1562dbd48f
//


import SwiftUI

struct DropDownMenu: View {
    @State var expand = false
    @State var selected: String? = nil
    
    // (Optionally) Provide these arguments
    var list: [String]
    var hint: String = "Expand"
    var hintColor: Color = .gray
    var background: Color? = nil
    var expandedHeight: CGFloat = 200
    
    
    var body: some View {
        VStack {
            HStack {
                if (self.selected == nil){
                    Text(hint)
                        .foregroundColor(hintColor)
                }
                else {
                    Text(self.selected!)
                }
                Spacer()
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
                        HStack{
                            Button(action: {
                                self.expand.toggle()
                                self.selected = item
                            }) {
                                Text(item).padding(.vertical)
                            }
                            .padding(.horizontal, 7)
                            .foregroundColor(.black)
                            
                            Spacer()
                        }
                    }
                }
            .frame(height: expandedHeight)
            }
            
        }
        .padding(7)
        .background(background)
        .cornerRadius(7)
        .animation(.spring())
        
    }
}

struct DropDownMenu_Previews: PreviewProvider {
    static var previews: some View {
        DropDownMenu(
            list: (1...100).map{"Item \($0)"},
            hint: "Choose an Item",
            hintColor: Color.yellow,
            background: Color.green,
            expandedHeight: 200
        )
    }
}
