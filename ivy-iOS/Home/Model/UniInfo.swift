//
//  UniInfo.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-24.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine

class UniInfo: ObservableObject {
    @Published var uniLogoUrl = Utils.uniLogoPath()
}
