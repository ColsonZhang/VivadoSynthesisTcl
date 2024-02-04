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
set project_name "project_1"
set save_name "save-1"
set log_name "log-1"

set board_part "xcu200-fsgd2104-2-e"
set repo_path [get_absolute_path "../"]
set project_path "${repo_path}/vivado/${project_name}"

# 创建项目
create_project_with_board $project_name $project_path $board_part

# 综合设定
set xdc_name "Syn_200M"
# set xdc_name "Syn_100M"
set rpt_enable { 1 1 0 0 }
set rpt_name { "uti-hier" "timing" "power" "clock" }
set synth_run "synth_1"

# 设置参数解析函数
proc func_param_float {curr_scheme} {
    set N [lindex $curr_scheme 0]
    set es [lindex $curr_scheme 1]
    set parameter_string "N=$N es=$es"
    return $parameter_string
}

# 设置综合参数
set all_scheme { {32 6} { 16 4 } {8 2} }

# 进行综合
set top_module "posit_mult_nodsp"
set func_param func_param_float

synthesize  $top_module $all_scheme $repo_path $func_param $project_name \
            $save_name $log_name $synth_run $xdc_name $rpt_enable $rpt_name

set top_module "add_mult_nodsp"
set func_param func_param_float

synthesize  $top_module $all_scheme $repo_path $func_param $project_name \
            $save_name $log_name $synth_run $xdc_name $rpt_enable $rpt_name

# 退出vivado
exit