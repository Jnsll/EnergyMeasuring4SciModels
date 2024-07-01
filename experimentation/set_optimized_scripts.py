import csv
import re
import shutil
from pathlib import Path

regex_origin = re.compile('./../resource(.*/)(.*m)')
regex_optimized = re.compile('./../resource(.*m)')


## TO DO
# create file with scripts to run for experimentS

def create_file_for_experimentaton(list_script_paths):
    list_scripts_format =  "\n".join(list_script_paths)
    with open("Experimentation_scripts.csv", "w") as file:
            file.write(list_scripts_format)

FILES = ["../GPT/resource/Optimzation_results/optimized_gpt3/OptimizedMatlabScripts_reasonings.csv", "../GPT/resource/Optimzation_results/optimized_gpt4/OptimizedMatlabScripts_reasonings.csv", "../GPT/resource/Optimzation_results/optimized_llama/OptimizedMatlabScripts_reasonings.csv", "../GPT/resource/Optimzation_results/optimized_mixtral/OptimizedMatlabScripts_reasonings.csv"]

scripts_to_run_list = []
for file in FILES:
    with open("../GPT/resource/Optimzation_results/optimized_gpt3/OptimizedMatlabScripts_reasonings.csv", "r") as csvfile: 
        reader_variable = csv.reader(csvfile)
        for row in reader_variable:
            origin_script = row[0]
            optimized_script = row[1]
            #print(origin_script)
            p = re.match(regex_origin, origin_script)
            p_optimized = re.match(regex_origin, optimized_script)
            if p:
                path_to_original_script = p.group(1)
                name_original_script = p.group(2)
                #print("Orginial script:", path_to_original_script, name_original_script)
            if p_optimized:
                path_optimized_script = p_optimized.group(1)
                name_optimized_script = p_optimized.group(2)
                #print("optimized:", optimized_script)
            try:
                #3print("../GPT/resource" + str(optimized_script))
                #print(Path(".." + str(path_to_original_script) + "/") )
                if p:
                    print("../GPT/resource" + str(path_optimized_script) + str(name_optimized_script), ".." + str(path_to_original_script))
                    shutil.copy("../GPT/resource" + str(path_optimized_script) + str(name_optimized_script), ".." + str(path_to_original_script))
                    scripts_to_run_list.append(str(path_to_original_script) + str(name_optimized_script))
                    scripts_to_run_list.append(str(path_to_original_script) + str(name_original_script))
                        
            except:
            #    print("Error with the file copy!")
                
                #print(path_to_original_script, name_original_script)
                #print("optimized:", optimized_script)
                print("error for", "../GPT/resource" + str(optimized_script))

create_file_for_experimentaton(scripts_to_run_list)




