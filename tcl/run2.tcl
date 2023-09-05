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
set xdc_name "Syn_100M"
set rpt_enable { 1 1 0 0 }
set rpt_name { "uti-hier" "timing" "power" "clock" }
set synth_run "synth_1"

# 设置参数解析函数
proc func_param_float_fixed {curr_scheme} {
    set the_exp [lindex $curr_scheme 0]
    set the_man [lindex $curr_scheme 1]
    set the_fx_man [lindex $curr_scheme 2]
    set the_dw  [expr {$the_exp+$the_man}]
    set the_fx_dw [expr {$the_fx_man+1}]
    set parameter_string "FP_DEW=$the_exp FP_DFW=$the_man FP_DW=$the_dw FX_DW=$the_fx_dw FX_DFW=$the_fx_man"
    return $parameter_string
}

# 设置综合参数
# set all_scheme { { 8 7 6 } }
set scheme_path "/P3PSSD/zhangshen/workspace/SPN/VivadoSynthesisTcl/source/param/param_float_fixed.txt"
set all_scheme [read_scheme_from_file $scheme_path]

# 进行综合
set top_module "mul_float_fixed_regout_regin"
set func_param func_param_float_fixed
synthesize  $top_module $all_scheme $repo_path $func_param $project_name \
            $save_name $log_name $synth_run $xdc_name $rpt_enable $rpt_name


set top_module "add_float_fixed_regout_regin"
set func_param func_param_float_fixed
synthesize  $top_module $all_scheme $repo_path $func_param $project_name \
            $save_name $log_name $synth_run $xdc_name $rpt_enable $rpt_name


set top_module "mul_float_fixed_regout_regin_nodsp"
set func_param func_param_float_fixed
synthesize  $top_module $all_scheme $repo_path $func_param $project_name \
            $save_name $log_name $synth_run $xdc_name $rpt_enable $rpt_name
