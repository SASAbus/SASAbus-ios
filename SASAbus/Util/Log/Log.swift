import Foundation
import SwiftyBeaver

class Log {

    static let log = SwiftyBeaver.self
    
    static func setup() {
        let console = ConsoleDestination()
        
        console.format = "$DHH:mm:ss$d $L $M"
        
        console.levelString.verbose = "💜 VERB:"
        console.levelString.debug = "💚 DEBG:"
        console.levelString.info = "💙 INFO:"
        console.levelString.warning = "💛 WARN:"
        console.levelString.error = "❤️ CRIT:"
        
        Log.log.addDestination(console)
    }
    
    static func verbose(_ message: @autoclosure () -> Any, _file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        log.custom(level: .verbose, message: message, file: _file, function: function, line: line, context: context)
    }
    
    /// log something which help during debugging (low priority)
    static func debug(_ message: @autoclosure () -> Any, _file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        log.custom(level: .debug, message: message, file: _file, function: function, line: line, context: context)
    }
    
    /// log something which you are really interested but which is not an issue or error (normal priority)
    static func info(_ message: @autoclosure () -> Any, _file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        log.custom(level: .info, message: message, file: _file, function: function, line: line, context: context)
    }
    
    /// log something which may cause big trouble soon (high priority)
    static func warning(_ message: @autoclosure () -> Any, _file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        log.custom(level: .warning, message: message, file: _file, function: function, line: line, context: context)
    }
    
    /// log something which will keep you awake at night (highest priority)
    static func error(_ message: @autoclosure () -> Any, _file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        log.custom(level: .error, message: message, file: _file, function: function, line: line, context: context)
    }
}
