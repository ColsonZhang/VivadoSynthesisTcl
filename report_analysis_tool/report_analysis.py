import os
import re

def extract_timing_report_file(file_path):
    requirement_pattern =r"\s*Requirement:\s+(\d+\.\d+)ns"
    slack_pattern_met = r"Slack \(MET\) :\s+(\d+\.\d+)ns"
    slack_pattern_vio = r"Slack \(VIOLATED\) :\s+(-?\d+\.\d+)ns"
    
    requirement = None
    slack = None

    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            match_requirement = re.match(requirement_pattern, line)
            if match_requirement:
                requirement = float(match_requirement.group(1))        
            match_slack_met = re.match(slack_pattern_met, line)
            match_slack_vio = re.match(slack_pattern_vio, line)
            if match_slack_met:
                slack = float(match_slack_met.group(1))
            if match_slack_vio:
                slack = float(match_slack_vio.group(1))
            if requirement is not None and slack is not None:
                break

    return requirement, slack


def extract_uti_report_data(file_path):
    table_data = {}
    with open(file_path, 'r', encoding='utf-8') as file:
        in_table = 0

        for line in file:
            if in_table == 2 :
                if line.strip().startswith('|'):
                    row_data = line.strip().split('|')
                    if len(row_data) >= 11:
                        instance = row_data[1].strip()
                        module = row_data[2].strip()
                        try:
                            total_luts = int(row_data[3].strip())
                            logic_luts = int(row_data[4].strip())
                            lutrams = int(row_data[5].strip())
                            srls = int(row_data[6].strip())
                            ffs = int(row_data[7].strip())
                            ram_b36 = int(row_data[8].strip())
                            ram_b18 = int(row_data[9].strip())
                            uram = int(row_data[10].strip())
                            dsp_blocks = int(row_data[11].strip())
                            
                            table_data['instance'] = instance
                            table_data['Module']= module,
                            table_data['Total_LUTs'] = total_luts
                            table_data['Logic_LUTs'] = logic_luts
                            table_data['LUTRAMs'] = lutrams
                            table_data['SRLs'] = srls
                            table_data['FFs'] = ffs
                            table_data['RAMB36'] = ram_b36
                            table_data['RAMB18'] = ram_b18
                            table_data['URAM'] = uram
                            table_data['DSP_Blocks'] = dsp_blocks

                            if module == '(top)':         #只读第一行top数据
                                break
                        except ValueError:
                            print(f"Error parsing data for instance: {instance}")
            elif line.strip() == '+--------------------------------+-------------------+------------+------------+---------+------+-----+--------+--------+------+------------+':
                in_table = in_table + 1 
                
    return table_data

def write_matching_filenames_to_txt(folder_path, output_dir):
    matching_files = []
    specified_timing = 'timing'
    specified_uti = 'uti-hier'

    # 获取父目录的文件夹名即模块名
    parent_folder = os.path.basename(os.path.abspath(folder_path))
    output_file = os.path.join(output_dir, f'{parent_folder}.txt')

    with open(output_file, 'w') as file:
        # 写入模块名作为第一行
        file.write(f"Module: {parent_folder}\n\n")
        file.write('-'*50+'Timing Report' +'-'*50+ '\n\n')
        column_names = ["DEW", "DFW", "Slack(ns)", "Requirement(ns)"]
        column_widths = [12] * len(column_names)
        format_string = ''.join(f"{{:<{width}}}" for width in column_widths)
        file.write(format_string.format(*column_names) + '\n')
        file.write('='*12*len(column_names)+'\n')
        
        # 时序报告
        for root, dirs, files in os.walk(folder_path):
            for filename in files:
                if specified_timing in filename:
                    file_dir = os.path.join(folder_path, filename)
                    requirement, slack = extract_timing_report_file(file_dir)
                    match = re.match(r"timing-(\d+)\s(\d+).rpt", filename)
                    if match:
                        DEW = int(match.group(1))  # 获取第一个数字
                        DFW = int(match.group(2))  # 获取第二个数字
                    write_line = format_string.format((DEW), (DFW), (slack), (requirement)) + '\n' 
                    file.write(write_line)
        file.write('-'*55+'Timing Report End'+'-'*55+ '\n\n') 
        
        #资源报告
        file.write('-'*60+'Uti Report'+('-'*60 )+ '\n')
        column_names = ["DEW", "DFW", "Total LUTs", "Logic LUTs", "LUTRAMs", "SRLs", "FFs", "RAMB36", "RAMB18", "URAM", "DSP Blocks"]
        column_widths = [12] * len(column_names)
        # 使用zip将列名和对齐宽度组合，并构建格式化字符串
        format_string = ''.join(f"{{:<{width}}}" for width in column_widths)
        file.write(format_string.format(*column_names) + '\n')
        file.write('='*12*len(column_names)+'\n')
        for root, dirs, files in os.walk(folder_path):            
            for filename in files:
                if specified_uti in filename:
                    write_line = ''
                    file_dir = os.path.join(folder_path, filename)
                    uti_data = extract_uti_report_data(file_dir)
                    match = re.match(r"uti-hier-(\d+)\s(\d+).rpt", filename)
                    if match:
                        DEW = int(match.group(1))  # 获取第一个数字
                        DFW = int(match.group(2))  # 获取第二个数字
                        write_line = "{:<12}{:<12}".format((DEW),(DFW))
                    for uti_name, data in uti_data.items():
                        if uti_name != 'instance' and uti_name != 'Module':
                            write_line = write_line + "{:<12}".format(data)        
                    write_line = write_line + "\n"
                    file.write(write_line)

    print(f"All {parent_folder} timing and uti-hie reports written to : {output_file}.")
    return matching_files

def report_parsing(src_folder_path,output_path):
    # 为每个文件夹创建一个 TXT 文件
    for root, dirs, files in os.walk(src_folder_path):
        for directory in dirs:
            subdir_path = os.path.join(src_folder_path, directory)
            write_matching_filenames_to_txt(subdir_path, output_path)


if __name__ == "__main__":
    # 输出文件夹
    output_path = '/home/ningbin/workspace/SPN/VivadoSynthesisTcl/report_analysis_tool/output'
    # 填入需要解析的上级目录文件夹
    src_folder_path = '/home/ningbin/workspace/SPN/VivadoSynthesisTcl/output/report/Syn_200M'
    report_parsing(src_folder_path,output_path)
