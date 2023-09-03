

proc extract_utilization { log_file } {
    # 定义要提取的利用率信息的关键字
    set lut_keyword "CLB LUTs"
    set dsp_keyword "DSPs"

    # 定义存储利用率信息的变量
    set lut_count 0
    set dsp_count 0

    # 读取日志文件，并提取所需的利用率信息
    set fid [open $log_file r]
    while {[gets $fid line] != -1} {
        # 去除行前后的空白字符
        set line [string trim $line]
        # 判断行是否以关键字开头
        if {[string match "| $lut_keyword*" $line] && $lut_count == 0} {
            # 利用竖线和空格分割当前行，并提取 LUT 数目
            set parts [split $line "|"]
            set lut_count [string trim [lindex $parts 2]]
        }
        if {[string match "| $dsp_keyword*" $line] && $dsp_count == 0} {
            # 利用竖线和空格分割当前行，并提取 DSP 数目
            set parts [split $line "|"]
            set dsp_count [string trim [lindex $parts 2]]
        }
        # 如果 LUT 和 DSP 数目都被提取到了，就跳出循环
        if {$lut_count != 0 && $dsp_count != 0} { break }
    }
    close $fid
    return [list $lut_count $dsp_count]
}


proc extract_power { rpt_file pwr_keyword } {
    set part_keyword "By Hierarchy"
    set pwr_list {}

    set flag 0
    set cnt 0
    set fid [open $rpt_file r]
    while {[gets $fid line] != -1} {
        set line [string trim $line]
        if {[string match "*$part_keyword*" $line] && $flag==0} {
            set flag 1 ; continue 
        }
        if { [expr {[string match "*$pwr_keyword*" $line] && $flag==1}] || $cnt>0 } {
            set parts [split $line "|"]
            set instance [string trim [lindex $parts 1]]
            set power [string trim [lindex $parts 2]]
            lappend pwr_list [list $instance $power] ; 
            incr cnt ;
            if { $cnt > 2 } { break } 
        }
    }
    return $pwr_list 
}

proc extract_utilization_hier { rpt_file } {
    set file_handle [open $rpt_file r]
    set report_data [read $file_handle]
    close $file_handle

    # 搜索包含特定标识行的位置
    set start_line [string first "Instance" $report_data]
    # 从该行开始，找到不包含括号的感兴趣行
    set lines [split [string range $report_data $start_line end] "\n"]
    set interested_lines {}
    set cnt 0
    foreach line $lines {
        if {[string match "+*" $line]} {
            incr cnt; 
            if { $cnt == 2 } { break }
            continue;
        }
        if {$cnt > 0} {
            set parts [split $line "|"]
            set name [string trim [lindex $parts 1]]
            if {![string match {*(*} $name]} {
                lappend interested_lines $line
            }        
        }
    }

    set data_uti {}
    # 使用split函数按照竖线进行分割，并提取total LUTs、FFs和DSP Blocks
    foreach line $interested_lines {
        set fields [split $line "|"]
        set instance [string trim [lindex $fields 1]]
        set total_luts [string trim [lindex $fields 3]]
        set ffs [string trim [lindex $fields 7]]
        set dsp_blocks [string trim [lindex $fields 11]]

        lappend data_uti [list $instance $total_luts $ffs $dsp_blocks] 
    }
    return $data_uti
}

proc extract_slack {filename} {
    set file [open $filename r]
    set lines [split [read $file] "\n"]
    close $file
    
    set start_line 0
    set line_count [llength $lines]
    
    for {set i 0} {$i < $line_count} {incr i} {
        set line [lindex $lines $i]
        if {[string match "*required time*" $line]} {
            set start_line $i
        }
    }

    set time_required 0
    set time_arrival 0
    set slack 0
    if { $start_line > 0 } {
        for {set i $start_line} {$i < $line_count} {incr i} {
            set line [lindex $lines $i]
            if {[string match "*required time*" $line]} {
                set parts [regexp -all -inline {\S+} $line]
                set time_required [lindex $parts 2]
            }
            if {[string match "*arrival time*" $line]} {
                set parts [regexp -all -inline {\S+} $line]
                set time_arrival [lindex $parts 2]
            }
            if {[string match "*slack*" $line]} {
                set parts [regexp -all -inline {\S+} $line]
                set slack [lindex $parts 1]
            }
        }
    }
    
    return [list $slack $time_required $time_arrival]
}
