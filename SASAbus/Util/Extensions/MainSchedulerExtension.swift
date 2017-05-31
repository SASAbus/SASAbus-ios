import Foundation
import RxSwift
import RxCocoa

extension MainScheduler {

    public static let background = ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background)
}