proc sourcehere { dir the_file } {
    set current_dir [file dirname [file normalize [info script]]]
    set script_dir "${current_dir}/${dir}"
    cd $script_dir; source $the_file; cd $current_dir
}

# 加载脚本
sourcehere scripts synthesize.tcl
sourcehere scripts update.tcl
sourcehere scripts vivado.tcl

# 拷贝hdl文件
set sourceFolder "/P3PSSD/zhangshen/workspace/SPN/SPN/SPN_HDL/src"
set destinationFolder "/P3PSSD/zhangshen/workspace/SPN/VivadoSynthesisTcl/source/vsrc"
copyFolder $sourceFolder $destinationFolder

# 项目设定
set project_name "project_2"
set save_name "save-2"
set log_name "log-2"

set board_part "xcu200-fsgd2104-2-e"
set repo_path [get_absolute_path "../"]
set project_path "${repo_path}/vivado/${project_name}"

# 创建项目
create_project_with_board $project_name $project_path $board_part

# 综合设定
set xdc_name "Syn_200M"
set rpt_enable { 1 1 0 0 }
set rpt_name { "uti-hier" "timing" "power" "clock" }
set synth_run "synth_1"

# 设置参数解析函数
proc func_param_float {curr_scheme} {
    set exp [lindex $curr_scheme 0]
    set man [lindex $curr_scheme 1]
    set dw  [expr {$exp+$man}]
    set parameter_string "DEW=$exp DFW=$man DW=$dw"
    return $parameter_string
}

# 设置综合参数
# --------------------------------------------------
set all_scheme { { 8 7 } }
# --------------------------------------------------
# set scheme_path "/P3PSSD/zhangshen/workspace/SPN/SPN/SPN_HDL/tools/xilinx/tcl/scheme_mul_float2.txt"
# set all_scheme [read_scheme_mul_float $scheme_path]
# --------------------------------------------------
# set all_scheme { }
# for {set j 3} {$j <= 12} {incr j} {
#     for {set i 4} {$i <= 20} {incr i} {
#         lappend all_scheme [subst {$j $i}]
#     }
# }

# 进行综合
set top_module "mul_float_regout_regin"
set func_param func_param_float

synthesize  $top_module $all_scheme $repo_path $func_param $project_name \
            $save_name $log_name $synth_run $xdc_name $rpt_enable $rpt_name

# set top_module "mul_float_regout_regin_nodsp"
# set func_param func_param_float

# synthesize  $top_module $all_scheme $repo_path $func_param $project_name \
#             $save_name $log_name $synth_run $xdc_name $rpt_enable $rpt_name

# set top_module "add_float_regout_regin"
# set func_param func_param_float

# synthesize  $top_module $all_scheme $repo_path $func_param $project_name \
#             $save_name $log_name $synth_run $xdc_name $rpt_enable $rpt_name

# 退出vivado
exit