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
fibonacci_index = 35



def run_matlab_experimentation(input_file, repetition_number, fibonacci_index):
    """
    Runs a series of MATLAB scripts multiple times with energy measurements, after a warm-up phase.

    This function performs the following steps:
    1. Defines MATLAB scripts to run by extracting the entry point files from the provided input file.
    2. Ensures that each MATLAB script is executed a specified number of times.
    3. Performs a warm-up sequence using Fibonacci computation to mitigate external factors in energy measurements.
    4. Executes the MATLAB scripts and measures their energy consumption.

    Parameters:
    input_file (str): Path to the file containing the MATLAB projects' entry point files.
    repetition_number (int): The number of times each MATLAB script should be executed.
    fibonacci_index (int): The index for the Fibonacci sequence used in the warm-up phase.

    Returns:
    None

    Examples:
    >>> run_matlab_experimentation('matlab_projects.txt', 5, 10)

    Note:
    The `create_list_experimental_executions_in_random_order`, `warm_up_with_fibonacci_sequence`, 
    and `execute_multiple_matlab_scripts_from_list` functions must be defined for this function to work correctly.
    The warm-up phase helps to stabilize the system before actual measurements are taken.
    """
    # Defining Matlab scripts to run by extracting Matlab projects entry point files from given file
    # Ensuring that each Matlab script will be run repetition_number of times
    scripts_executions = create_list_experimental_executions_in_random_order(input_file, repetition_number)

    # Check if there are scripts to execute
    if scripts_executions is None:
        sys.exit(1)
    
    # Warm Up to mitigate external factors in the energy measurements
    warm_up_with_fibonacci_sequence(fibonacci_index)

    #Execution of the Matlab scripts with energy measurments
    execute_multiple_matlab_scripts_from_list(scripts_executions)


def create_list_experimental_executions_in_random_order(input_file, repetition_number):
    """
    Creates a randomized list of MATLAB script executions for experimentation.

    This function performs the following steps:
    1. Reads MATLAB project scripts from the specified input file.
    2. Sets up the experimentation by repeating each script a specified number of times.
    3. Adds baseline executions.
    4. Shuffles the order of script executions randomly.
    5. Stores the execution order in a CSV file for tracking purposes.

    Parameters:
    input_file (str): Path to the file containing the MATLAB projects' entry point files, with one script per line.
    repetition_number (int): The number of times each MATLAB script should be repeated in the experiment.

    Returns:
    list: A shuffled list of MATLAB script executions, including baseline executions.

    Examples:
    >>> create_list_experimental_executions_in_random_order('matlab_projects.txt', 5)
    ['script1.m', 'script2.m', '', 'script1.m', '', 'script2.m', ...]

    Note:
    The resulting execution order is saved in a CSV file located at "../output/executions_order.csv".
    Baseline executions are represented by empty strings in the list.
    """

    ### Extracting scripts of Matlab projects to run
    try:
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

        ## Storing the execution order into a csv file to be able to match energy output files to each corresponding Matlab script
        format_file_execution_order = "\n".join(scripts_executions) # 1 line = 1 execution : format of the input file
        # write out the CSV
        with open("../output/executions_order.csv", "w") as file:
            file.write(format_file_execution_order)
        return scripts_executions
    except FileNotFoundError:
        print('Something went wrong, the file was not found. Please check that the input file exists.')
        return None
    

def warm_up_with_fibonacci_sequence(fibonacci_index):
    """
    Measures the time taken to compute the Fibonacci number at the specified index.

    This function calculates the Fibonacci number at the given index using a 
    recursive approach and measures the duration of this computation to provide
    a warm-up duration.

    Parameters:
    fibonacci_index (int): The position in the Fibonacci sequence to calculate. 

    Returns:
    float: The duration of the computation in seconds.

    Examples:
    >>> warm_up_with_fibonacci_sequence(10)
    Duration of Warm up: 0.002345
    0.002345
    """
    warm_up_start = time.time()
    fibonacci(fibonacci_index)
    warm_up_end = time.time()
    warm_up_duration = (warm_up_end - warm_up_start)
    print("Duration of Warm up:", warm_up_duration)
    
    return warm_up_duration


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


def execute_multiple_matlab_scripts_from_list(scripts_executions):
    """
    Executes a list of MATLAB scripts and measures their energy consumption.

    This function iterates over a list of MATLAB script names, executes each script,
    and measures the energy consumption for each execution. The progress of the 
    executions is displayed using a progress bar.

    Parameters:
    scripts_executions (list): A list of MATLAB script names to be executed. 
                               Baseline executions are represented by empty strings.

    Returns:
    None

    Examples:
    >>> execute_multiple_matlab_scripts_from_list(['script1.m', 'script2.m', '', 'script1.m'])
    Execution: script1.m
    Execution: script2.m
    Execution: 
    Execution: script1.m

    Note:
    The `execute_matlab_script_and_measure_energy` function must be defined for this function to work correctly.
    """
    ### Running experiment executions
    count = 0
    for execution in tqdm(scripts_executions): #shows progress bar with tqdm (equivalent of for loop)
        print("Execution:", execution)
        count += 1
        execute_matlab_script_and_measure_energy(execution, count)

def execute_matlab_script_and_measure_energy(execution, count):
    """
    Executes a MATLAB script and measures the energy consumption, recording the elapsed time.

    This function constructs and runs a command to execute a MATLAB script inside a Docker container.
    It measures the execution time and energy consumption, saving the results to specified output files.

    Parameters:
    execution (str): The MATLAB script to be executed.
    count (int): A counter to uniquely identify the output files for each execution.

    Returns:
    None

    Examples:
    >>> execute_matlab_script_and_measure_energy('script1.m', 1)
    Elapsed Time (s): 123.456

    Note:
    This function uses the `subprocess.run` method to execute the command and `time.sleep` to introduce
    a delay between executions. The `SLEEP_TIME` constant should be defined elsewhere in the code.
    The energy metrics and elapsed time are saved in CSV files in the "../output" directory.
    """
    script_command = ["/home/tdurieux/git/EnergiBridge/target/release/energibridge" ,"--summary" ,"--output", 
    "/home/june/EnergyMeasuring4SciModels/output/energy_metrics_" + str(count) + ".csv" ,
    "-c" ,"/home/june/EnergyMeasuring4SciModels/output/output_simulation_"+ str(count) + ".txt" ,
    "docker" ,"run", "--rm", "-v", "/home/june/EnergyMeasuring4SciModels/sampling:/sampling" , 
    "-v", "/home/june/EnergyMeasuring4SciModels/output:/output", 
    "-v" ,"/home/june/EnergyMeasuring4SciModels/matlab.dat:/licenses/license.lic", 
    "-e", "MLM_LICENSE_FILE=/licenses/license.lic", "matlab-r2021b-toolbox" ,
    "-batch", "run('" + str(execution) + "');exit();"]

    start = time.time()
    result = subprocess.run(script_command)
    end = time.time()
    elapsed_time_execution = (end - start)
    with open("../output/execution_elapsed_time_" + str(count) + ".csv", "w") as file_time:
        file_time.write(str(elapsed_time_execution))
    print("Elapsed Time (s):", elapsed_time_execution)
    time.sleep(SLEEP_TIME)

q

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--file')   
    parser.add_argument('-rep', '--repetition')
    args = parser.parse_args()

    run_matlab_experimentation(args.file, int(args.repetition), fibonacci_index)

