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
    var thisUserIsOrg: Bool
    @ObservedObject var eventTabVM = EventTabViewModel();
    var screenWidth: CGFloat = 300
    
    var body: some View {
        VStack{
            List{
                ForEach(eventTabVM.exploreAllEventsVMs) { eventItemVM in
                    ExploreAllEventsItemView(thisUserIsOrg: self.thisUserIsOrg, eventItemVM: eventItemVM)
                }
            }
        }
    }
}
