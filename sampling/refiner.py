import numpy as np
import pandas as pd
import os
import sys
import time
import requests
from datetime import datetime


# call this function with parameters <YOUR GITHUB LOGIN NAME> <YOUR GITHUB TOKEN>


def remaining_rate():
    response = requests.get("https://api.github.com/rate_limit", auth=(sys.argv[1], sys.argv[2])).json()
    return response["rate"]["remaining"], response["rate"]["reset"]

def check_remaining():
    remaining, reset = remaining_rate()
    if remaining < 2:
        current_timestamp = int(time.time())
        time_to_wait = reset - current_timestamp
        if time_to_wait > 0:
            print(f"Waiting for {time_to_wait} seconds.")
            time.sleep(time_to_wait)


def sleeep(x):
    print("Search failed: ", x.json()["message"], " Waiting 3s ...")
    time.sleep(3)


def API_commit_URL(name):
    return f"https://api.github.com/repos/{name}/commits"


def API_repo_URL(name):
    return f"https://api.github.com/repos/{name}"


def str_to_datetime(dt_str):
    return datetime.strptime(dt_str, '%Y-%m-%dT%H:%M:%SZ')


def analyze_commits(commits):
    first_commit, last_commit = datetime(2025, 1, 1), datetime(1970, 1, 1)
    authors = set()
    for commit in commits:
        try:
            authors.add(commit["author"]["id"])
        except:
            try:
                authors.add(commit["commit"]["author"]["name"])
            except:
                pass  # corrupted commit?
        date = str_to_datetime(commit["commit"]["author"]["date"])
        if date > last_commit:
            last_commit = date
        if date < first_commit:
            first_commit = date

    return len(commits), first_commit.isoformat(), last_commit.isoformat(), (
            last_commit - first_commit).total_seconds() / 86400, len(authors)

remaining_rate()
list_path = "projects_Matlab.csv"
list_path_refined = "projects_Matlab_refined.csv"

if not os.path.isfile(list_path_refined):
    project_list = pd.read_csv(list_path).sample(frac=1).reset_index(drop=True)

    project_list["#commits"] = -1
    project_list["first commit"] = ".."
    project_list["last commit"] = ".."
    project_list["project life time (s)"] = -1
    project_list["#contributors"] = -1
    project_list["online"] = True
    project_list["included"] = True

else:
    print("Resuming refining ...")
    project_list = pd.read_csv(list_path_refined)

for i in range(len(project_list)):
    if not np.isnan(project_list.loc[i, "#commits"]) or project_list.loc[i, "included"] is False:
        continue
    print(i, project_list.loc[i, "name"])
    tries = 0
    while True:
        tries += 1
        commits = requests.get(API_commit_URL(project_list.iloc[i]["name"]), auth=(sys.argv[1], sys.argv[2]))
        if commits.ok or tries > 5:
            break
        else:
            check_remaining()
        sleeep(commits)
    if tries > 5:
        project_list.loc[i, ["online", "included"]] = (False, False)
        continue
    commits = commits.json()
    project_list.loc[
        i, ["#commits", "first commit", "last commit", "project life time (s)", "#contributors"]] = analyze_commits(
        commits)

    if i % 100 == 0:
        project_list.to_csv(list_path_refined, index=False)
    if i % 500 == 0:
        remaining, reset = remaining_rate()
        print(f"{remaining} actions Remaining, currently")
project_list.to_csv(list_path_refined, index=False)

    # project_list[".m lines"] = -1
    # project_list["stars"] = -1

    #repo = requests.get(API_repo_URL(project_list.iloc[i]["name"]), auth=(sys.argv[1], sys.argv[2]))
    # project_list.loc[i, "stars"] = repo["stargazers_count"]
