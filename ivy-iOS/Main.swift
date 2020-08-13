//
//  Main.swift
//  ivy-iOS
//
//  Created by paul dan on 2020-07-09.
//  Copyright © 2020 ivy. All rights reserved.
//

//sceneDelegate calls this view as the first view when the app is launched.
//Since you can login without an account it will always open up to Main



import SwiftUI

struct Main: View {
    @State var loginPresented = false
    
    var body: some View {
        VStack{
            Text("MAIN").padding()
            Button(action: {
                self.loginPresented.toggle()
            }){
                Text("Go to login").sheet(isPresented: $loginPresented){
                    LoginView()
                }
            }
        }
    }
}


struct Main_Previews: PreviewProvider {
    static var previews: some View {
        Main()
    }
}
