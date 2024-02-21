import pandas as pd
import datetime


#prefilters:
#   mirror = false
#   forks = false
#   language = Matlab
#   date in [2008-01-01, 2024-02-14]
df = pd.read_csv("projects_Matlab.csv")
print(f"Before filtering #projects: {len(df)}")


#filter private/offline projects
df = df[df["online"] == True]
print(f"Still online #projects: {len(df)}")

#filter all projects by mathworks
df = df[~df["name"].str.startswith("mathworks")]
print(f"Projects not by Mathworks: {len(df)}")


#FILTER QUANTILES
df["first_commit_in_seconds"] = df["first commit"].apply(lambda x: datetime.datetime.strptime(x, '%Y-%m-%dT%H:%M:%S').timestamp())
def filter_quantiles(df, column):
    quantile = 0.2
    df = df[df[column] > df[column].quantile(quantile)]
    print(f"After filtering projects by >>{column.upper()}<<, we still have: {len(df)}")
    return df

filters = ["#contributors", "stars", "project life time (s)", "#commits", "first_commit_in_seconds"]
for f in filters:
    df = filter_quantiles(df, f)


df.drop("first_commit_in_seconds", axis=1)
df.to_csv("projects_filtered.csv", index=False)



