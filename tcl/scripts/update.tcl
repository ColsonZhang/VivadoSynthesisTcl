proc copyFolder {srcFolder destFolder} {
    if {![file isdirectory $srcFolder]} {
        puts "源文件夹不存在: $srcFolder"
        return
    }
    
    if {[catch {exec cp -r $srcFolder $destFolder} output]} {
        puts "复制文件夹时出现错误: $output"
    } else {
        puts "文件夹复制成功！"
    }
}
