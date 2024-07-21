import csv
import re
import shutil
from pathlib import Path
import os

regex_origin = re.compile('./../resource(.*/)(.*m)')

PREFIXE_PATH_TO_OPTIMISATION = "../GPT/resource"

def create_file_for_experimentaton(list_script_paths):
    list_scripts_format =  "\n".join(list_script_paths)
    with open("Experimentation_human_scripts.csv", "w") as file:
            file.write(list_scripts_format)

FILES = ["../GPT/resource/Optimization-Human/human_optimized_files.csv"]

scripts_to_run_list = []
for file in FILES:
    with open(file, "r") as csvfile: 
        reader_variable = csv.reader(csvfile, delimiter=';')
        for row in reader_variable:
            path = Path(row[0])
            path_to_project_folder = path.parent.absolute()
            shutil.copy(".." + str(row[1]) , ".." + str(path_to_project_folder))
            path_human_opt = Path(row[1])
            filename = path_human_opt.name
            scripts_to_run_list.append(str(path_to_project_folder) + "/" + str(filename))

create_file_for_experimentaton(scripts_to_run_list)
