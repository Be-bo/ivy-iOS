//
//  OrganizationSignup.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-11.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

// Main View
struct OrganizationSignup: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isClub = true

    var body: some View {
        ZStack(){
            Background()
            
            VStack(alignment: .leading){
                
                TextField("Email", text: $email)
                
                Divider()
                    .padding(.bottom)
                
                TextField("Password", text: $password)
                
                Divider()
                    .padding(.bottom)
                
                TextField("Confirm Password", text: $confirmPassword)
                
                Divider()
                    .padding(.bottom)
                
                Toggle(isOn: $isClub) {
                    Text("We are a club")
                }
                .padding(.bottom)
                .padding(.bottom)
                
                StandardButton(action: {}){
                    Text("Organization Sign Up")
                }
            }
            .padding()
            
        }
    }
}

// Preview
struct OrganizationSignup_Previews: PreviewProvider {
    static var previews: some View {
        OrganizationSignup()
    }
}


/** SubViews **/

// Gradient and logo
struct Background: View {
    var body: some View {
        ZStack(alignment: .top) {
            
        
            LinearGradient(
                gradient: .init(colors: [AssetManager.ivyGreen, Color.white, Color.white, Color.white]),
                startPoint: .bottom,
                endPoint: .top)
            .edgesIgnoringSafeArea(.all)
            
            Image("LogoGreen")
            .resizable()
            .frame(width: 200, height: 200, alignment: .center)
        }
    }
}
