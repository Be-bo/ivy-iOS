//
//  Login.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-10.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack(){
            ZStack(alignment: .top){
                LinearGradient(gradient: .init(colors: [AssetManager.ivyGreen, Color.white, Color.white, Color.white]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
                Image("LogoWhite")
                    .resizable().frame(width: 200, height: 200, alignment: .top)
            }
            
            VStack(alignment: .leading){
                TextField("Email", text: $email)
                Divider()
                    .padding(.bottom)
                TextField("Password", text: $password)
                Divider()
                    .padding(.bottom)
                    .padding(.bottom)
                StandardButton(action: {}){
                    Text("Log in")
                }
                
                
                HStack{
                    Spacer()
                    Button(action: {}){
                        Text("Student Signup")
                            .foregroundColor(AssetManager.ivyGreen)
                    }
                }
                .padding(.top, 50)
                
                HStack{
                    Spacer()
                    Button(action: {}){
                        Text("Organization Signup")
                            .foregroundColor(AssetManager.ivyGreen)
                    }
                }
                .padding(.top)
                
            }
            .padding()
        }
    }
}


struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
