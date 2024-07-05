import csv
import re
import shutil
from pathlib import Path

regex_origin = re.compile('./../resource(.*/)(.*m)')

PREFIXE_PATH_TO_OPTIMISATION = "../GPT/resource"

def create_file_for_experimentaton(list_script_paths):
    list_scripts_format =  "\n".join(list_script_paths)
    with open("Experimentation_scripts.csv", "w") as file:
            file.write(list_scripts_format)

FILES = ["../GPT/resource/Optimzation_results/optimized_gpt3/OptimizedMatlabScripts_reasonings.csv", "../GPT/resource/Optimzation_results/optimized_gpt4/OptimizedMatlabScripts_reasonings.csv", "../GPT/resource/Optimzation_results/optimized_llama/OptimizedMatlabScripts_reasonings.csv", "../GPT/resource/Optimzation_results/optimized_mixtral/OptimizedMatlabScripts_reasonings.csv"]

scripts_to_run_list = []
for file in FILES:
    with open(file, "r") as csvfile: 
        reader_variable = csv.reader(csvfile)
        for row in reader_variable:
            origin_script = row[0]
            optimized_script = row[1]
            line_match_regex_for_original_script = re.match(regex_origin, origin_script)
            line_match_regex_for_optimized_script = re.match(regex_origin, optimized_script)
            if line_match_regex_for_original_script:
                path_to_original_script = line_match_regex_for_original_script.group(1)
                name_original_script = line_match_regex_for_original_script.group(2)
            if line_match_regex_for_optimized_script:
                path_optimized_script = line_match_regex_for_optimized_script.group(1)
                name_optimized_script = line_match_regex_for_optimized_script.group(2)
            try:
                if line_match_regex_for_original_script:
                    print(PREFIXE_PATH_TO_OPTIMISATION + str(path_optimized_script) + str(name_optimized_script), ".." + str(path_to_original_script))
                    shutil.copy(PREFIXE_PATH_TO_OPTIMISATION + str(path_optimized_script) + str(name_optimized_script), ".." + str(path_to_original_script))
                    scripts_to_run_list.append(str(path_to_original_script) + str(name_optimized_script))
                    if str(path_to_original_script) + str(name_original_script) not in scripts_to_run_list:
                        scripts_to_run_list.append(str(path_to_original_script) + str(name_original_script))
            except:
                print("Error for", PREFIXE_PATH_TO_OPTIMISATION + str(optimized_script))

create_file_for_experimentaton(scripts_to_run_list)




