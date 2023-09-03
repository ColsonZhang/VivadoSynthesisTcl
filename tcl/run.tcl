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
set board_part "xcu200-fsgd2104-2-e"
set repo_path [get_absolute_path "../"]
set project_path "${repo_path}/vivado/${project_name}"

# 创建项目
create_project_with_board $project_name $project_path $board_part

# 综合谁当
set top_module "mul_float_regout_regin"
set all_scheme { { 8 7 } { 8 15 } }
set xdc_name "Syn_100M"
set rpt_enable { 1 1 0 0 }
set rpt_name { "uti-hier" "timing" "power" "clock" }
set save_name "save-1"
set log_name "log-1"
set synth_run "synth_1"


# 进行综合
synthesize  $top_module $all_scheme $repo_path $project_name \
            $save_name $log_name $synth_run $xdc_name $rpt_enable $rpt_name
