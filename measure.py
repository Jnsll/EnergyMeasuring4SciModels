import subprocess
import sys
import random
#import pandas as pd


#### TO DO
## Store the list and order of experiments that are run (storing the shuffled list)
## Include timestamp + type of experiment (matlab project + repetition number) in the name of the energy measurement output file
## Do we want to store simulation outputs? (would save storage)
## Include DRAM metric in EnergiBridge


### Experimental Parameters
random.seed(42)
repetition_number = 30
BASELINE = False

#sci_script = "/scripts/deep-photo-styletransfer/gen_laplacian/gen_laplacian.m"

### Extracting scripts of Matlab projects to run
with open("test.csv", "r") as file:
    lines = file.read().splitlines()

### Exerimentation set up
## Repetition
scripts_executions = lines * repetition_number
## Shuffle of Matlab project to run
random.shuffle(scripts_executions)
print(scripts_executions)

if BASELINE is True:
    matlab_command = "exit();"
else:
    matlab_command = "run('" + str(execution) + "');exit();"
### Running experiment executions

count = 0
if BASELINE is False:
    for execution in scripts_executions:
        count += 1
        script_command = ["/home/tdurieux/git/EnergiBridge/target/release/energibridge" ,"--summary" ,"--output", "./output/energy_metrics_" + str(count) + ".csv" ,"-c" ,"./output/output_simulation_"+ str(count) + ".txt" ,"docker" ,"run", "--rm", "-v", "./scripts:/scripts" ,"-v" ,"./matlab.dat:/licenses/license.lic", "-e", "MLM_LICENSE_FILE=/licenses/license.lic", "matlab-r2021b-toolbox" ,"-batch", str(matlab_command)]
        result = subprocess.run(script_command)
else:
    for count in range(1,repetition_number+1):
        script_command = ["/home/tdurieux/git/EnergiBridge/target/release/energibridge" ,"--summary" ,"--output", "./output/energy_metrics_" + str(count) + ".csv" ,"-c" ,"./output/output_simulation_"+ str(count) + ".txt" ,"docker" ,"run", "--rm", "-v", "./scripts:/scripts" ,"-v" ,"./matlab.dat:/licenses/license.lic", "-e", "MLM_LICENSE_FILE=/licenses/license.lic", "matlab-r2021b-toolbox" ,"-batch", str(matlab_command)]
        result = subprocess.run(script_command)





if __name__ == "__main__":
    parser = argparse.ArgumentParser()

#parser.add_argument('-rep', '--repetitions')      # option that takes a value
    parser.add_argument('-base', '--baseline',
                    action='store_true')
    args = parser.parse_args()

    if args.baseline is True:
        BASELINE = True