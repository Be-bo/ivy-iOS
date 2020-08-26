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
    
    // (Optionally) Provide these arguments
    @Binding var selected: String?
    var list: [String]
    var hint: String = "Expand"
    var hintColor: Color = Color.gray.opacity(0.5)
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
                    .foregroundColor(hintColor)
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
            else {
                Divider()
                    .background(selected != nil ? Color.green : hintColor)
                    .padding(.bottom)
            }
            
        }
        .padding(.horizontal, expand ? 7 : 0)
        .padding(.vertical, expand ? 7 : 0)
        .background(background)
        .cornerRadius(7)
        .animation(.spring())
        
    }
}
