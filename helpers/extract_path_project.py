import pandas as pd
import random
import os
from pathlib import Path
import argparse


random.seed(42)
selection_ratio = 0.05


def create_file_with_subset_entrypoints_from_random_selection(selection_ratio):
    """
    Creates a file with a subset of MATLAB script entry points selected randomly.

    This function reads a CSV file containing MATLAB script entry points, randomly selects a subset 
    based on the provided selection ratio, and writes the selected entry points to a new file.

    Parameters:
    selection_ratio (float): The ratio of projects to be selected from the total available projects. 
                             Should be a value between 0 and 1.

    Returns:
    None

    Examples:
    >>> create_file_with_subset_entrypoints_from_random_selection(0.1)
    10 unique projects being selected ( 0.1 %).

    Note:
    The CSV file 'entrypoints_no_crashes_only.csv' should be located in the 'matlab_energy_analysis' 
    directory, one level up from the current file's directory. The function calls 
    `create_file_from_projects_entrypoints` to create the new file with the selected entry points.
    """
    path_to_project_folder = Path(__file__).parents[1]
    path_to_entrypoint_file = os.path.join(path_to_project_folder, 'matlab_energy_analysis/entrypoints_no_crashes_only.csv')
    df_projects = pd.read_csv(path_to_entrypoint_file) 
    list_projects = df_projects["scriptName"].tolist()

    random_selected_projects = random.sample(list_projects, int(len(list_projects)*selection_ratio))

    if len(random_selected_projects) != len(set(random_selected_projects)):
        print("Warning! Some projects being selected more than once!")
    else:
        print(str(len(random_selected_projects)), "unique projects being selected (", str(float(len(random_selected_projects)/len(list_projects))), "%).")
        create_file_from_projects_entrypoints(random_selected_projects, selection_ratio)


def create_file_from_projects_entrypoints(projects_names, selection_ratio):
    """
    Creates a CSV file with a list of MATLAB project entry points, formatted with a specified directory path.

    This function takes a list of project names, prepends a directory path to each project name, and writes 
    the formatted project names to a new CSV file.

    Parameters:
    projects_names (list): A list of project entry point names (strings).

    Returns:
    None

    Examples:
    >>> create_file_from_projects_entrypoints(['project1.m', 'project2.m'])
    # This will create a file 'Projects_Time_Study_no_crashes_sample_demo.csv' with the content:
    # /sampling/repos_projects_filtered_top100stars/project1.m
    # /sampling/repos_projects_filtered_top100stars/project2.m

    Note:
    The output file 'Projects_Time_Study_no_crashes_sample_demo.csv' will be created in the current directory.
    """
    append_str = "/sampling/repos_projects_filtered_top100stars/"
    projects_names = [append_str + sub for sub in projects_names]
    list_proj_format =  "\n".join(projects_names)
    with open("Scripts_no_crashes_" + str(selection_ratio) + "_sample.csv", "w") as file:
        file.write(list_proj_format)


def create_file_with_all_entrypoints():
    """
    Creates a CSV file with all MATLAB project entry points.

    This function reads a CSV file containing MATLAB project entry points, extracts all the entry points, 
    and writes them to a new CSV file using the `create_file_from_projects_entrypoints` function.

    Parameters:
    None

    Returns:
    None

    Examples:
    >>> create_file_with_all_entrypoints()
    # This will create a file 'Projects_Time_Study_no_crashes_sample_demo.csv' with all project entry points
    # formatted with the specified directory path.

    Note:
    The input CSV file 'entrypoints_no_crashes_only.csv' should be located in the 'matlab_energy_analysis' 
    directory, one level up from the current file's directory.
    """
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
    
    create_file_with_subset_entrypoints_from_random_selection(float(args.ratio))