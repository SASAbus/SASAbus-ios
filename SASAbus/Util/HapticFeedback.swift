import Foundation
import AudioToolbox

class HapticFeedback {
    
    private static func getSupportLevel() -> Int {
        return (UIDevice.current.value(forKey: "_feedbackSupportLevel") as? Int) ?? 0;
    }
    
    static func peek() {
        switch getSupportLevel() {
        case 1:
            AudioServicesPlaySystemSound(1519)
        case 2:
            iPhone7Peek()
        default:
            // Not supported
            break
        }
    }
    
    static func nope() {
        switch getSupportLevel() {
        case 1:
            AudioServicesPlaySystemSound(1521)
        case 2:
            iPhone7Peek()
        default:
            // Not supported
            break
        }
    }
    
    private static func iPhone7Peek() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
}
