//
// Created by Alex Lardschneider on 03/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension MainScheduler {

    public static let background = ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background)
}