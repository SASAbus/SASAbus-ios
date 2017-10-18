import Foundation
import SwiftValidator

extension Validator {

    func isValid() -> Bool {
        self.validateAllFields()
        return errors.isEmpty
    }
}
