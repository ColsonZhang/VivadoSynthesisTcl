source "synthesize.tcl"
source "update.tcl"

set sourceFolder "/P3PSSD/zhangshen/workspace/SPN/SPN/SPN_HDL/src"
set destinationFolder "/P3PSSD/zhangshen/workspace/SPN/VivadoSynthesisTcl/source/vsrc"
copyFolder $sourceFolder $destinationFolder

set top_module "mul_float_regout_regin"
set all_scheme { { 8 7 } { 8 15 } { 8 23 }  }

synthesize $top_module $all_scheme
