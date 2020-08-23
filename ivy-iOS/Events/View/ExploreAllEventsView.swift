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
    var screenWidth: CGFloat = 300
    
    var body: some View {
        VStack{
            List{
                ForEach(eventTabVM.exploreAllEventsVMs) { eventItemVM in
                    ExploreAllEventsItemView(eventItemVM: eventItemVM, screenWidth: self.screenWidth)
                }
            }
        }
    }
}
