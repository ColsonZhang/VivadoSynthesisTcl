source "function.tcl"

proc create_project_with_board {project_name project_path board_part} {
    create_project $project_name $project_path -part $board_part
}
