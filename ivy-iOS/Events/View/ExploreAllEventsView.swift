//
//  EventsTabView.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-22.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase


struct ExploreAllEventsView: View {
    @ObservedObject var eventTabVM = EventTabViewModel();
    @State private var loadingWheelAnimating = true
    var screenWidth: CGFloat = 300
    
    var body: some View {
        VStack{
            List{
                ForEach(eventTabVM.exploreAllEventsVMs) { eventItemVM in
                    ExploreAllEventsItemView(eventItemVM: eventItemVM)
                }
                
                if !eventTabVM.eventRepo.exploreAllEventsLoaded {
                    HStack {
                        Spacer()
                        ActivityIndicator($loadingWheelAnimating)
                            .onAppear {
                                //if we haven't started to load explore all events yet, load them now
                                if (self.eventTabVM.exploreAllEventsVMs.count < 1) {
                                    self.eventTabVM.eventRepo.loadExploreAll(start: true)
                                } else {
                                    self.eventTabVM.eventRepo.loadExploreAll()
                                }
                            }
                        Spacer()
                    }
                }
            }
        }
    }
}
