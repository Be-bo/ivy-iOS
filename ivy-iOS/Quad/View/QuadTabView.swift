//
//  QuadTabView.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-11-19.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase


struct QuadTabView: View {
    
    var thisUserRepo: ThisUserRepo
    @ObservedObject var quadTabVM = QuadTabViewModel()
    @State private var settingsPresented = false
    @State private var loadingWheelAnimating = true

    
    var body: some View {
        
        NavigationView {
            
            // MARK: Horizontal List of people
            HStack {
                List(){
                    ForEach(quadTabVM.quadUsersVMs){ userVM in
                        QuadCardView(userVM: userVM)
                    }
                    
                    if quadTabVM.usersLoaded == false {
                        HStack{
                            Spacer()
                            ActivityIndicator($loadingWheelAnimating)
                                .onAppear {
                                    self.quadTabVM.fetchNextBatch()
                                }
                            Spacer()
                        }
                    }
                }
                
                if(quadTabVM.quadUsersVMs.count < 1){
                    Text("No other users on this campus :(")
                        .font(.system(size: 25))
                        .foregroundColor(AssetManager.ivyLightGrey)
                        .multilineTextAlignment(.center)
                        .padding(30)
                }
            }
            
            // MARK: Nav Bar
            .navigationBarItems(
                leading:
                        HStack {
                            Button(action: {
                                self.settingsPresented.toggle()
                            }) {
                                Image(systemName: "gear").font(.system(size: 25))
                                    .sheet(isPresented: $settingsPresented){
                                        SettingsView(thisUserRepo: self.thisUserRepo)
                                }
                            }
                            
                            FirebaseImage(
                                path: Utils.uniLogoPath(),
                                placeholder: AssetManager.uniLogoPlaceholder,
                                width: 40,
                                height: 40,
                                shape: RoundedRectangle(cornerRadius: 0)
                            )
                            .padding(.leading, (UIScreen.screenWidth/2 - 75))
                            
                        }.padding(.leading, 0)
            )
            
        }
        
        

        
    }
}
