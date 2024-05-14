import subprocess
import sys
import random
import argparse
import time
from tqdm import tqdm

### Experimental Parameters
random.seed(42)

repetition_number = 30
SLEEP_TIME = 5




def fibonacci(n):
    """
    Calculate the nth Fibonacci number using a recursive approach.

    The Fibonacci sequence is a series of numbers where each number is the sum
    of the two preceding ones, starting from 0 and 1. That is:
    F(0) = 0, F(1) = 1
    and F(n) = F(n-1) + F(n-2) for n > 1.

    Parameters:
    n (int): The position in the Fibonacci sequence to calculate. Must be a non-negative integer.

    Returns:
    int: The nth Fibonacci number.

    Examples:
    >>> fibonacci(0)
    0
    >>> fibonacci(1)
    1
    >>> fibonacci(10)
    55
    """
    # First Fibonacci number is 0
    if n<= 0:
       return 0
    # Second Fibonacci number is 1
    elif n == 1:
        return 1
    else:
        return fibonacci(n-1)+fibonacci(n-2)


def run_experiments_matlab(input_file, repetition_number):
    ### Extracting scripts of Matlab projects to run
    with open(input_file, "r") as file:
        lines = file.read().splitlines()

    ### Exerimentation set up
    ## Repetitions
    # Matlab projects
    scripts_executions = lines * repetition_number
    # Baseline executions
    scripts_executions += [""] * repetition_number

    ## Shuffle of Matlab project to run
    random.shuffle(scripts_executions)

    ## Storing the execution order into a csv file
    format_file_execution_order = "\n".join(scripts_executions) # 1 line = 1 execution
    # write out the CSV
    with open("../output/executions_order.csv", "w") as file:
        file.write(format_file_execution_order)


    ### Warm Up
    warm_up_start = time.time()
    fibonacci(35)
    warm_up_end = time.time()
    warm_up_duration = (warm_up_end - warm_up_start)
    print("Duration of Warm up:", warm_up_duration)


    ### Running experiment executions
    count = 0
    for execution in tqdm(scripts_executions):
        print("Execution:", execution)
        count += 1
        script_command = ["/home/tdurieux/git/EnergiBridge/target/release/energibridge" ,"--summary" ,"--output", "./output/energy_metrics_" + str(count) + ".csv" ,"-c" ,"./output/output_simulation_"+ str(count) + ".txt" ,"docker" ,"run", "--rm", "-v", "./sampling:/sampling" , "-v", "./time_study:/time_study", "-v", "./output:/output", "-v" ,"./matlab.dat:/licenses/license.lic", "-e", "MLM_LICENSE_FILE=/licenses/license.lic", "matlab-r2021b-toolbox" ,"-batch", "run('" + str(execution) + "');exit();"]
        start = time.time()
        result = subprocess.run(script_command)
        end = time.time()
        elapsed_time_execution = (end - start)
        with open("../output/execution_elapsed_time_" + str(count) + ".csv", "w") as file_time:
            file_time.write(str(elapsed_time_execution))
        print("Elapsed Time (s):", elapsed_time_execution)
        time.sleep(SLEEP_TIME)
    
        





if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--file')   
    parser.add_argument('-rep', '--repetition')
    args = parser.parse_args()

    run_experiments_matlab(args.file, args.repetition)

