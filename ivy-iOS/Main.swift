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
    @State private var selection = 0
    
    var body: some View {
        Text("Main News Feed")
            .font(.title)
    }
    
}




//shows preview of the UI code..
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Main()
    }
}
