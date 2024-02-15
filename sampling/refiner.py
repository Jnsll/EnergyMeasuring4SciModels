import os.path
import pandas as pd

list_path = f"./projects_Matlab.csv"
project_list = pd.read_csv(list_path)

print(project_list)