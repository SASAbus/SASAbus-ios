import Foundation

extension UIScreen {
    
    var isPhone4: Bool {
        return self.nativeBounds.size.height == 960;
    }
    
    var isPhone5: Bool {
        return self.nativeBounds.size.height == 1136;
    }
    
    var isPhone6: Bool {
        return self.nativeBounds.size.height == 1334;
    }
    
    var isPhone6Plus: Bool {
        return self.nativeBounds.size.height == 2208;
    }
}
