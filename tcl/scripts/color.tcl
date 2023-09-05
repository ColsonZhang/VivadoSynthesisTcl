set c_black "\033\[0;30m"
set c_red "\033\[0;31m"
set c_green "\033\[0;32m"
set c_yellow "\033\[0;33m"
set c_blue "\033\[0;34m"
set c_magenta "\033\[0;35m"
set c_cyan "\033\[0;36m"
set c_white "\033\[0;37m"
set c_reset "\033\[0m"

set colorDict {
    black   "\033\[0;30m"
    red     "\033\[0;31m"
    green   "\033\[0;32m"
    yellow  "\033\[0;33m"
    blue    "\033\[0;34m"
    magenta "\033\[0;35m"
    cyan    "\033\[0;36m"
    white   "\033\[0;37m"
    reset   "\033\[0m"
}


proc print {args} {
    # Example : 
    # print "Error occurred!" 
    # print "Error occurred!" -color red
    # print -color red "Error occurred!" 

    set text ""
    set color ""

    set colorDict {
        black   "\033\[0;30m"
        red     "\033\[0;31m"
        green   "\033\[0;32m"
        yellow  "\033\[0;33m"
        blue    "\033\[0;34m"
        magenta "\033\[0;35m"
        cyan    "\033\[0;36m"
        white   "\033\[0;37m"
        reset   "\033\[0m"
    }

    set exist_ckey 0
    set idx_color 0
    foreach arg $args {
        if {[string match "-color" $arg] || [string match "-c" $arg]} {
            set exist_ckey 1; break
        }
        incr idx_color 
    }

    if { $exist_ckey } {
        for {set idx 0} {$idx < [llength $args]} { incr idx } {
            set arg [lindex $args $idx]
            if { $idx == [expr {$idx_color+1}] } {
                set color [dict get $colorDict $arg]
            } else {
                if { $idx != $idx_color } {
                    set text $arg
                }
            }
        }        
    } else {
        if {[llength $args] == 1} {
            set text [lindex $args 0]
        } else {
            error "Input args error !!! "
        }
    }

    puts "${color}${text}\033\[0m"
}