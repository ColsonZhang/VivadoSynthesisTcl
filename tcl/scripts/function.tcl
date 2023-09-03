
proc currentDateTime { } {
    set currentDateTime [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
    return $currentDateTime
}

proc checkAndCreatePath {path} {
    if {![file exists $path]} {
        if {[catch {file mkdir $path} err]} {
            error "无法创建路径: $path\n错误信息: $err"
        } else {
            puts "路径已创建: $path"
        }
    } else {
        puts "路径已存在: $path"
    }
}

proc get_absolute_path { relativePath } {
    set scriptPath [file normalize [file dirname [info script]]]
    set absPath [file normalize [file join $scriptPath $relativePath]]
    return $absPath
}

proc write_file { file_name content } {
    set fid [open $file_name a]
    puts $fid "$content"
    close $fid
}

proc dump_log { log_file text  } {
    set the_time [currentDateTime]
    set fulltext "${the_time}\n${text}"
    write_file $log_file $fulltext
}

proc dump_put_log { log_file text } {
    set the_time [currentDateTime]
    set fulltext "${the_time}\n${text}"
    write_file $log_file $fulltext
    puts $fulltext
}

proc read_scheme_from_file { file_path } {
    set file_handle [open $file_path r]
    set file_data [read $file_handle]
    close $file_handle

    set all_scheme {}
    foreach line [split $file_data "\n"] {
        if {[string trim $line] ne ""} {
            lappend all_scheme [split $line ","]
        }
    }
    return $all_scheme
}

