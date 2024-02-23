#finds all MATLAB projects in GitHub which can then later be sampled from
#creates columns: name, URL, stars

import os.path
import sys
import time

import pandas as pd
import requests

from datetime import datetime, timezone, timedelta


# call this function with parameters <YOUR GITHUB LOGIN NAME> <YOUR GITHUB TOKEN>

def date_format(dt):
    return dt.isoformat()


def date_prior(dt):
    return dt - timedelta(days=3)


def today():
    return datetime(2024, 2, 14).date()           #datetime.now(timezone.utc).date()


def construct_query(current_page, day):
    return f'https://api.github.com/search/repositories?q=language:{language}+created:{date_format(date_prior(day))}..{date_format(day)}+mirror:false+template:false&per_page={per_page}&page={current_page}'


def sleeep(x):
    print("Search failed: ", x.json()["message"], " Waiting 30s ...")
    time.sleep(30)


languages = ["Matlab"]

sort = "stars"
order = "desc"
per_page = 100
maximum_projects = 370*1000

day = today()

for language in languages:
    print("Search for language: " + language)
    list_path = f"./projects_{language}.csv"

    if not os.path.isfile(list_path):
        project_list = pd.DataFrame(columns=["name", "URL", "stars"])
    else:
        project_list = pd.read_csv(list_path)

    while project_list.shape[0] < maximum_projects:

        for current_page in range(1, 11):
            x = requests.get(construct_query(current_page, day), auth=(sys.argv[1], sys.argv[2]))
            if not x.ok:
                sleeep(x)
                current_page -= 1
                continue



            projects = x.json()["items"]
            print(f"Search found {len(projects)} repositories for {date_format(day)}")

            for i in range(0, len(projects)):
                project_list.loc[project_list.shape[0]] = [projects[i]["full_name"], projects[i]["html_url"], projects[i]["stargazers_count"]]

            print(f"New project count: {project_list.shape[0]}\n")
            if x.json()["total_count"] > 1000:
                print(f"TOO MANY ({x.json()['total_count']}) projects FOR DATE: " + date_format(day))
            if x.json()["total_count"] < current_page * per_page:
                break

        day = date_prior(day) - timedelta(days=1)
        project_list.to_csv(list_path, index=False)
        if day < datetime(2008, 1, 1).date():
            break

    project_list.sort_values(by=["name"]).to_csv(list_path, index=False)
