import pandas as pd
import random
import os
from pathlib import Path


random.seed(42)
selection_ratio = 0.05



def create_file_from_projects_entrypoints(projects_names):
    append_str = "/sampling/repos_projects_filtered_top100stars/"
    projects_names = [append_str + sub for sub in projects_names]
    list_proj_format =  "\n".join(projects_names)
    with open("Projects_Time_Study_no_crashes_sample_demo.csv", "w") as file:
        file.write(list_proj_format)


def create_file_with_subset_entrypoints_from_random_selection(selection_ratio):
    path_to_project_folder = Path(__file__).parents[1]
    path_to_entrypoint_file = os.path.join(path_to_project_folder, 'matlab_energy_analysis/entrypoints_no_crashes_only.csv')
    df_projects = pd.read_csv(path_to_entrypoint_file) 
    list_projects = df_projects["scriptName"].tolist()

    random_selected_projects = random.sample(list_projects, int(len(list_projects)*selection_ratio))

    if len(random_selected_projects) != len(set(random_selected_projects)):
        print("Warning! Some projects being selected more than once!")
    else:
        print(str(len(random_selected_projects)), "unique projects being selected (", str(float(len(random_selected_projects)/len(list_projects))), "%).")
        create_file_from_projects_entrypoints(random_selected_projects)

def create_file_with_entrypoints():
    path_to_project_folder = Path(__file__).parents[1]
    path_to_entrypoint_file = os.path.join(path_to_project_folder, 'matlab_energy_analysis/entrypoints_no_crashes_only.csv')
    df_projects = pd.read_csv(path_to_entrypoint_file) 
    list_projects = df_projects["scriptName"].tolist()
    create_file_from_projects_entrypoints(list_projects)



if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-r', '--ratio')   
    args = parser.parse_args()

    #if no ratio, create full entrypoints file
    
    create_file_with_entrypoints_from_random_selection(args.ratio)