source function.tcl
source extract.tcl

proc headinfo {log_file top_module text} {
    set thetime [currentDateTime]
    write_file $log_file "-----------------\n${thetime}\n-----------------"
    write_file $log_file "Top Module = ${top_module}"
    write_file $log_file $text
}

# 递归获取目录下的所有文件路径
proc get_files_recursive {dir} {
    set file_extension_pattern {(\.sv|\.v)$}

    set file_list {}
    foreach file [glob -directory $dir *] {
        if {[file isdirectory $file]} {
            lappend file_list {*}[get_files_recursive $file]
        } else {
            set file_extension [file extension $file]
            if {[regexp $file_extension_pattern $file_extension]} {
                lappend file_list $file
            }
        }
    }
    return $file_list
}

# 更新HDL源码
proc update_source_from_dir {directory} {
    # 递归获取文件路径
    set file_list [get_files_recursive $directory]
    # 使用 add_files 命令一次性添加所有文件
    add_files -fileset sources_1 $file_list
    # 更新源码层次
    update_compile_order -fileset sources_1
}

# 创建综合任务
proc check_and_create_run { synth_run_name } {
    # 获取已创建的 run 列表
    set runs [get_runs]
    # 检查指定名称的 run 是否已存在
    set run_exists 0
    foreach run $runs {
        if {[get_property NAME $run] eq $synth_run_name} {
            set run_exists 1
            break
        }
    }
    # 如果 run 不存在，则创建新的 run
    if {!$run_exists} {
        puts "Create the new run ${synth_run_name}"
        create_run -flow {Vivado Synthesis 2022} $synth_run_name
    } else {
        puts "Run '$synth_run_name' already exists."
    }
}

# 设定顶层模块
proc set_top_module {top_module} {
    set_property top $top_module [current_fileset]
    set new_top_module [get_property top [current_fileset]]
    if { $top_module != $new_top_module } {
        error "The top module can not be set successifully !!!"
    }
}

# 运行综合任务
proc run_synthesis { curr_param constrs_file synth_run } {
    # 读取约束
    read_xdc $constrs_file
    # 系统复位
    reset_run $synth_run
    # 设置参数
    set_property generic [subst $curr_param] [current_fileset]
    # 开始综合
    launch_runs $synth_run -jobs 64
    wait_on_run $synth_run
    # 检查综合结果
    set str_status [get_property STATUS [get_runs $synth_run]]
    set syn_status [expr {$str_status == "synth_design Complete!"}]
    return $syn_status
}

proc get_and_read_report { synth_run rpt_enable rpt_path} {
    set en_uti_hier     [lindex $rpt_enable 0]
    set en_timing       [lindex $rpt_enable 1]
    set en_power        [lindex $rpt_enable 2]
    set en_clock        [lindex $rpt_enable 3]

    set rpt_uti_hier    [lindex $rpt_path 0]
    set rpt_timing      [lindex $rpt_path 1]
    set rpt_power       [lindex $rpt_path 2]
    set rpt_clock       [lindex $rpt_path 3]

    set result {}
    open_run $synth_run -name $synth_run

    if {$en_uti_hier} {
        puts "Ready to report_utilization"
        report_utilization -hierarchical -file $rpt_uti_hier
        set result_uti [extract_utilization_hier $rpt_uti_hier]
        lappend result $result_uti
    } else {
        lappend result {}
    }

    if {$en_timing} {
        puts "Ready to report_timing"
        report_timing -file $rpt_timing
        set result_slack [extract_slack $rpt_timing ]
        lappend result $result_slack
    } else {
        lappend result {}
    }

    if {$en_power} {
        puts "Ready to report_power"
        report_power -file $rpt_power
        set result_pwr [extract_power $rpt_power $top_module ]
        lappend result $report_power
    } else {
        lappend result {}
    }

    if {$en_clock} {
        # report_clocks -file $rpt_clock
        # report_timint_summary -file $rpt_timing_summary
        # lappend result $report_power
        lappend result {}
    } else {
        lappend result {}
    }
    
    close_design
    # puts "Finish to get_and_read_report\nresult=${result}"
    return $result
}

proc get_syn_path { synth_run proj_path project_name } {
    return "${proj_path}/${project_name}/${project_name}.runs/${synth_run}/"
}

proc get_rpt_path { rpt_name output_path top_module curr_scheme } {
    set rpt_path {}
    foreach item $rpt_name {
        lappend rpt_path "${output_path}/report/${top_module}/${item}-${curr_scheme}.rpt"
    } 
    return $rpt_path
}

proc synthesize { top_module all_scheme repo_path func_param
            {project_name "project_1" }
            {save_name "save-1"} {log_name "log-1"} 
            {synth_run "synth_1"} {xdc_name "Syn_100M"} 
            {rpt_enable { 1 1 0 0 }}
            {rpt_name { "uti-hier" "timing" "power" "clock" }}
} {
    set source_path "${repo_path}/source/"
    set output_path "${repo_path}/output/"
    set proj_path   "${repo_path}/vivado/"

    set syn_path [get_syn_path $synth_run $proj_path $project_name]
    set src_path        "${source_path}/vsrc/"
    set constrs_file    "${source_path}/xdc/${xdc_name}.xdc"
    set save_file       "${output_path}/save/${save_name}.txt"
    set log_file        "${output_path}/log/${log_name}.txt"

    # 检查路径是否存在
    checkAndCreatePath "${output_path}/log"
    checkAndCreatePath "${output_path}/save"
    checkAndCreatePath "${output_path}/report/${top_module}"

    # vivado前期设定
    update_source_from_dir $src_path
    check_and_create_run $synth_run 
    set_top_module $top_module

    # 打印log头信息
    headinfo $log_file  $top_module "Scheme\tUtilization\tPower" 
    headinfo $save_file $top_module "Scheme\tUtilization\tPower" 

    # 进行batch-run
    set batch_len [llength $all_scheme]
    for { set idx 0 } { $idx < $batch_len } { incr idx } {
        set curr_scheme [lindex $all_scheme $idx]
        dump_put_log $log_file "$synth_run: Begin to snthesize ${top_module} with scheme=${curr_scheme}."

        set curr_param [$func_param $curr_scheme]
        set syn_status [run_synthesis $curr_param $constrs_file $synth_run]

        if {$syn_status} {
            set rpt_path [get_rpt_path $rpt_name $output_path $top_module $curr_scheme]
            dump_put_log $log_file "$synth_run: SUCCESS to snthesize ${top_module} with scheme=${curr_scheme}."
            dump_put_log $log_file "$synth_run: Begin to get the report of ${top_module} with scheme=${curr_scheme}."
            set syn_result [get_and_read_report $synth_run $rpt_enable $rpt_path ]
            write_file $save_file "${curr_scheme}\t${curr_param}\t${syn_result}"
            dump_put_log $log_file "$synth_run: SUCCESS to get the report of ${top_module} with scheme=${curr_scheme}."
        } else {
            dump_put_log $log_file "$synth_run: FAIL to snthesize ${top_module} with scheme=${curr_scheme}."
        }
    } 
}