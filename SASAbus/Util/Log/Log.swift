import Foundation
import SwiftyBeaver

class Log {

    static let log = SwiftyBeaver.self
    
    static var logTrees = [LogTree]()
    
    
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
    
    static func addLogTree(tree: LogTree) {
        logTrees.append(tree)
    }
    
    
    static func verbose(_ message: @autoclosure () -> Any, _file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        custom(level: .verbose, message: message, file: _file, function: function, line: line, context: context)
    }
    
    /// log something which help during debugging (low priority)
    static func debug(_ message: @autoclosure () -> Any, _file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        custom(level: .debug, message: message, file: _file, function: function, line: line, context: context)
    }
    
    /// log something which you are really interested but which is not an issue or error (normal priority)
    static func info(_ message: @autoclosure () -> Any, _file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        custom(level: .info, message: message, file: _file, function: function, line: line, context: context)
    }
    
    /// log something which may cause big trouble soon (high priority)
    static func warning(_ message: @autoclosure () -> Any, _file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        custom(level: .warning, message: message, file: _file, function: function, line: line, context: context)
    }
    
    /// log something which will keep you awake at night (highest priority)
    static func error(_ message: @autoclosure () -> Any, _file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        custom(level: .error, message: message, file: _file, function: function, line: line, context: context)
    }
    
    
    private static func custom(level: SwiftyBeaver.Level, message: @autoclosure () -> Any, file: String = #file, function: String = #function, line: Int = #line, context: Any? = nil) {
        log.custom(level: level, message: message, file: file, function: function, line: line, context: context)
        
        for tree in logTrees {
            let resolvedMessage: String = "\(message())"
            
            tree.log(level: level, message: resolvedMessage)
        }
    }
}
