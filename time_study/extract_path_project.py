import pandas as pd
import random

random.seed(42)
ratio_selection = 0.1





def create_file_from_projects_names(projects_names):
    append_str = "/sampling/repos_projects_filtered_top100stars/"
    projects_names = [append_str + sub for sub in projects_names]
    list_proj_format =  "\n".join(projects_names)
    with open("Projects_Time_Study_no_crashes_sample.csv", "w") as file:
        file.write(list_proj_format)


df_projects = pd.read_csv("../matlab_energy_analysis/entrypoints_no_crashes_only.csv") 
list_projects = df_projects["scriptName"].tolist()

random_selected_projects = random.sample(list_projects, int(len(list_projects)*ratio_selection))

if len(random_selected_projects) != len(set(random_selected_projects)):
    print("Warning! Some projects being selected more than once!")
else:
    print("Unique projects being selected.")
    create_file_from_projects_names(random_selected_projects)
