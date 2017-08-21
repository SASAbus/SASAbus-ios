//
// Themes.swift
//
// Copyright (c) 2015-2016 Damien (http://delba.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

extension LogThemes {

    public static let `default` = LogTheme(
        trace:   "#C8C8C8",
        debug:   "#0000FF",
        info:    "#00FF00",
        warning: "#FFFB00",
        error:   "#FF0000"
    )

    public static let `ansi` = LogTheme(
            trace:   "\\e[39m",
            debug:   "\\e[34m",
            info:    "\\e[92m",
            warning: "\\e[33m",
            error:   "\\e[31m",
            hex: false
    )

    public static let dusk = LogTheme(
        trace:   "#FFFFFF",
        debug:   "#526EDA",
        info:    "#93C96A",
        warning: "#D28F5A",
        error:   "#E44347"
    )

    public static let midnight = LogTheme(
        trace:   "#FFFFFF",
        debug:   "#527EFF",
        info:    "#08FA95",
        warning: "#EB905A",
        error:   "#FF4647"
    )

    public static let tomorrow = LogTheme(
        trace:   "#4D4D4C",
        debug:   "#4271AE",
        info:    "#718C00",
        warning: "#EAB700",
        error:   "#C82829"
    )

    public static let tomorrowNight = LogTheme(
        trace:   "#C5C8C6",
        debug:   "#81A2BE",
        info:    "#B5BD68",
        warning: "#F0C674",
        error:   "#CC6666"
    )

    public static let tomorrowNightEighties = LogTheme(
        trace:   "#CCCCCC",
        debug:   "#6699CC",
        info:    "#99CC99",
        warning: "#FFCC66",
        error:   "#F2777A"
    )

    public static let tomorrowNightBright = LogTheme(
        trace:   "#EAEAEA",
        debug:   "#7AA6DA",
        info:    "#B9CA4A",
        warning: "#E7C547",
        error:   "#D54E53"
    )
}
