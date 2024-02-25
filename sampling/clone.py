# clones repos
#corrects number of commits of repos, if > 30
#counts number of pull requests

import subprocess
import requests
import pandas as pd
import re
import os
import sys
# call this function with parameters <YOUR GITHUB LOGIN NAME> <YOUR GITHUB TOKEN>
#if more than a couple 100 projects get cloned at once (are part of 'repo_info_csv') sleep(3600) may have to be included



repo_info_csv = "projects_filtered_ge85p.csv"
repo_folder = "repos_" + repo_info_csv[:-4]


def count_commits(repo_name):
    commit_number = 0
    branches = requests.get(f"https://api.github.com/repos/{repo_name}/branches", auth=(sys.argv[1], sys.argv[2])).json()
    for b in branches:
        sha = b["commit"]["sha"]
        commits = requests.get(f"https://api.github.com/repos/{repo_name}/commits?{sha}&per_page=1&page=1", auth=(sys.argv[1], sys.argv[2]))
        headers = commits.headers["Link"]
        commit_number += int(re.findall(r'page=(\d+)', headers)[-1])
    return commit_number

def get_pull_requests(repo_name):
    pull_requests = requests.get(f"https://api.github.com/repos/{repo_name}/pulls?per_page=1&page=1", auth=(sys.argv[1], sys.argv[2]))
    if pull_requests.json():
        if "Link" in pull_requests.headers:
            headers = pull_requests.headers["Link"]
            pull_request_number = int(re.findall(r'page=(\d+)', headers)[-1])
        else:
            pull_request_number = 1
    else:
        pull_request_number = 0
    print(f"{repo_name} has {pull_request_number} pull requests.")
    for i in range(pull_request_number):
        pass
    return pull_request_number

def create_changedir():
    if not os.path.exists(repo_folder):
        os.makedirs(repo_folder)
        print(f"Created folder at {os.getcwd()}")
    os.chdir(repo_folder)


def clone(repo_name):
    command = ["git", "clone", f"https://github.com/{repo_name}.git"]
    process = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    if process.returncode != 0:
        raise RuntimeError(f"Git clone failed: {process.stderr}")

def clone_repo(repo_info):
    name = repo_info["name"]
    try:
        clone(name)
        repo_info["#commits"] = count_commits(name)
        repo_info["#pullrequests"] = get_pull_requests(name)
    except Exception as e:
        print(f"Something went wrong in cloning the repository {name}")
        print(e)
    return repo_info



df = pd.read_csv(repo_info_csv)

create_changedir()
df = df.apply(clone_repo, axis=1)
df.to_csv(repo_info_csv, index=False)
