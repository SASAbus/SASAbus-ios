import Foundation

public enum Level {
    case trace, debug, info, warning, error

    var description: String {
        return String(describing: self).uppercased()
    }
}

extension Level: Comparable {}

public func ==(x: Level, y: Level) -> Bool {
    return x.hashValue == y.hashValue
}

public func <(x: Level, y: Level) -> Bool {
    return x.hashValue < y.hashValue
}

open class Log {

    /// The logger state.
    public static var enabled: Bool = true

    /// The logger formatter.
    public static var formatter: Formatter = .default

    /// The logger theme.
    public static var theme: LogTheme = .ansi

    /// The minimum level of severity.
    public static var minLevel: Level = .trace

    /// The logger format.
    public static var format: String {
        return formatter.description
    }

    /// The logger colors
    public static var colors: String {
        return theme.description
    }

    /// The queue used for logging.
    private static let queue = DispatchQueue(label: "delba.log")

    /**
     Logs a message with a trace severity level.

     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    open static func trace(_ items: Any..., separator: String = " ", terminator: String = "\n", file: String = #file,
                           line: Int = #line, column: Int = #column, function: String = #function) {

        log(.trace, items, separator, terminator, file, line, column, function)
    }

    /**
     Logs a message with a debug severity level.

     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    open static func debug(_ items: Any..., separator: String = " ", terminator: String = "\n", file: String = #file,
                           line: Int = #line, column: Int = #column, function: String = #function) {

        log(.debug, items, separator, terminator, file, line, column, function)
    }

    /**
     Logs a message with an info severity level.

     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    open static func info(_ items: Any..., separator: String = " ", terminator: String = "\n", file: String = #file,
                          line: Int = #line, column: Int = #column, function: String = #function) {

        log(.info, items, separator, terminator, file, line, column, function)
    }

    /**
     Logs a message with a warning severity level.

     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    open static func warning(_ items: Any..., separator: String = " ", terminator: String = "\n", file: String = #file,
                             line: Int = #line, column: Int = #column, function: String = #function) {

        log(.warning, items, separator, terminator, file, line, column, function)
    }

    /**
     Logs a message with an error severity level.

     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    open static func error(_ items: Any..., separator: String = " ", terminator: String = "\n", file: String = #file,
                           line: Int = #line, column: Int = #column, function: String = #function) {

        log(.error, items, separator, terminator, file, line, column, function)
    }

    /**
     Logs a message.

     - parameter level:      The severity level.
     - parameter items:      The items to log.
     - parameter separator:  The separator between the items.
     - parameter terminator: The terminator of the log message.
     - parameter file:       The file in which the log happens.
     - parameter line:       The line at which the log happens.
     - parameter column:     The column at which the log happens.
     - parameter function:   The function in which the log happens.
     */
    private static func log(_ level: Level, _ items: [Any], _ separator: String, _ terminator: String, _ file: String,
                            _ line: Int, _ column: Int, _ function: String) {

        guard enabled && level >= minLevel else { return }

        let date = Date()

        let result = formatter.format(
                level: level,
                items: items,
                separator: separator,
                terminator: terminator,
                file: file,
                line: line,
                column: column,
                function: function,
                date: date
        )

        queue.async {
            Swift.print(result, separator: "", terminator: "")
        }
    }
}
