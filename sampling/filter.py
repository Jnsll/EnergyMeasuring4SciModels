#filters list of projects, so that the worst get kicked out
#or the number gets down to a manageable number

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
print(f"Still online #projects (we cannot analyze offline projects): {len(df)}")

#filter all projects by mathworks
df = df[~df["name"].str.contains("(?i)mathworks")]
print(f"Projects not by Mathworks (projects from Mathworks are not scientific): {len(df)}")


#sorted by stars
#only take TOP100
top = 100
df = df.sort_values("stars").iloc[-top:]
print(f"Taking TOP{top} projects, by number of stars")


# #FILTER QUANTILES
# df["first_commit_in_seconds"] = df["first commit"].apply(lambda x: datetime.datetime.strptime(x, '%Y-%m-%dT%H:%M:%S').timestamp())
# df["last_commit_in_seconds"] = df["last commit"].apply(lambda x: datetime.datetime.strptime(x, '%Y-%m-%dT%H:%M:%S').timestamp())
# def filter_quantiles(df, columnreason):
#     column, reason = columnreason
#     quantile = 0.85
#     df = df[df[column] >= df[column].quantile(quantile)]
#     print(f"After filtering projects by >>{column.upper()}<< ({reason}), we still have: {len(df)}")
#     return df
#
# filters = [("#contributors", "fewer contributors => toy project"), ("stars", "fewer stars => unimportant project"), ("#commits", "fewer commits => toy project"), ("project life time (d)", "short duration => toy project"), ("first_commit_in_seconds", "old project => irrelevant project setup for today"), ("last_commit_in_seconds", "last commit old => project long dead")]
# for f in filters:
#     df = filter_quantiles(df, f)
#df = df.drop("first_commit_in_seconds", axis=1)
#df = df.drop("last_commit_in_seconds", axis=1)


df.sort_values(by=["name"]).to_csv("projects_filtered.csv", index=False)