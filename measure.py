import subprocess
import sys
import random
#import pandas as pd
import argparse
import time

#### TO DO
## Store the list and order of experiments that are run (storing the shuffled list)
## Include timestamp + type of experiment (matlab project + repetition number) in the name of the energy measurement output file
## Do we want to store simulation outputs? (would save storage)
## Include DRAM metric in EnergiBridge


### Experimental Parameters
random.seed(42)
repetition_number = 30

#sci_script = "/scripts/deep-photo-styletransfer/gen_laplacian/gen_laplacian.m"


def run_experiments_matlab(repetition_number):
    #print("Is it a baseline exp:", baseline)
    #if baseline:
    #    for count in range(1,repetition_number+1):
    #        script_command = ["/home/tdurieux/git/EnergiBridge/target/release/energibridge" ,"--summary" ,"--output", "./output/energy_metrics_baseline_" + str(count) + ".csv" ,"-c" ,"./output/output_simulation_baseline_"+ str(count) + ".txt" ,"docker" ,"run", "--rm", "-v", "./scripts:/scripts" ,"-v" ,"./matlab.dat:/licenses/license.lic", "-e", "MLM_LICENSE_FILE=/licenses/license.lic", "matlab-r2021b-toolbox" ,"-batch", "exit();"]
    #        result = subprocess.run(script_command)
    #else:
    ### Extracting scripts of Matlab projects to run
    with open("test.csv", "r") as file:
        lines = file.read().splitlines()

    ### Exerimentation set up
    ## Repetitions
    # Matlab projects
    scripts_executions = lines * repetition_number
    # Baseline executions
    scripts_executions += [""] * repetition_number

    ## Shuffle of Matlab project to run
    random.shuffle(scripts_executions)
    print(scripts_executions)

    ## Storing the execution order into a csv file
    format_file_execution_order = "\n".join(scripts_executions) # 1 line = 1 execution
    # write out the CSV
    with open("executions_order.csv", "w") as file:
        file.write(format_file_execution_order)

    ### Running experiment executions
    count = 0
    for execution in scripts_executions:
        count += 1
        script_command = ["/home/tdurieux/git/EnergiBridge/target/release/energibridge" ,"--summary" ,"--output", "./output/energy_metrics_" + str(count) + ".csv" ,"-c" ,"./output/output_simulation_"+ str(count) + ".txt" ,"docker" ,"run", "--rm", "-v", "./scripts:/scripts" ,"-v" ,"./matlab.dat:/licenses/license.lic", "-e", "MLM_LICENSE_FILE=/licenses/license.lic", "matlab-r2021b-toolbox" ,"-batch", "run('" + str(execution) + "');exit();"]
        start = time.time()
        result = subprocess.run(script_command)
        end = time.time()
        elapsed_time_execution = (end - start)
        with open("execution_elapsed_time_" + str(count) + ".csv", "w") as file_time:
            file_time.write(elapsed_time_execution)
        print("Elapsed Time (s):", elapsed_time_execution)
        time.sleep(5)
    
        





if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    #parser.add_argument('-rep', '--repetitions')   
    #parser.add_argument('-base', '--baseline', action='store_true')
    args = parser.parse_args()
    run_experiments_matlab(repetition_number)

