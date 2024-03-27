
import os
import random

random.seed(42)

ratio_selection = 0.1

def create_file_from_projects_names(projects_names):
    append_str = "/sampling/repos_projects_filtered_top100stars/"
    projects_names = [append_str + sub for sub in projects_names]
    list_proj_format =  "\n".join(projects_names)
    with open("Projects_Time_Study.csv", "w") as file:
        file.write(list_proj_format)


path_to_projects_folder='../sampling/repos_projects_filtered_top100stars' 
dirlist = [ item for item in os.listdir(path_to_projects_folder) if os.path.isdir(os.path.join(path_to_projects_folder, item)) ]
print(dirlist)

random_selected_projects = random.sample(dirlist, int(len(dirlist)*ratio_selection))
print("number of selected projects:", len(random_selected_projects))
## Check that all the selected projects are different (i.e., unique)
if len(random_selected_projects) != len(set(random_selected_projects)):
    print("Warning! Some projects being selected more than once!")
else:
    print("Unique projects being selected.")
    create_file_from_projects_names(random_selected_projects)





