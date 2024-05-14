import re

with open("log.txt", "r") as file:
    lines = file.read().splitlines()
logs = '\n'.join(lines)
p = re.compile(r"m\nElapsed\sTime.+")
running_scripts_logs = p.findall(logs)
print(len(running_scripts_logs))