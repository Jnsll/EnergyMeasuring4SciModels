# Imports
import pandas as pd
import os
import re
from collections import defaultdict

TOTAL_NUMBER_CORES = 10
TOTAL_NUMBER_REPETITIONS = 30
INPUT_FOLDER = "./../../../EnergyMeasuring4SciModels/Output-new/output/"
script_name_test = "energy_metrics_chap11-chap11_2"

# Mapping of column names
COLUMN_MAPPING = {
    "time": "Time",
    "used_memory": "USED_MEMORY",
    "core_energy": lambda core: f"CORE{core}_ENERGY (J)"
}

def get_core_energy_column_name(number_core):
    return COLUMN_MAPPING["core_energy"](number_core)

def compute_core_energy_consumption(data_raw, number_core):
    column_name = get_core_energy_column_name(number_core)
    if column_name in data_raw.columns:
        start_energy = data_raw[column_name].iloc[0]
        end_energy = data_raw[column_name].iloc[-1]
        energy_consumption_core = float(end_energy - start_energy)
        return energy_consumption_core
    else:
        return 0.0

def compute_used_memory(column_name, data_raw):
    start_used_memory = data_raw[column_name].iloc[0]
    end_used_memory = data_raw[column_name].iloc[-1]
    used_memory_consumption = float(end_used_memory - start_used_memory)
    return used_memory_consumption

def compute_time_taken(column_name, data_raw):
    start_time = data_raw[column_name].iloc[0]
    end_time = data_raw[column_name].iloc[-1]
    time_taken = float(end_time - start_time)
    return time_taken

def process_energy_file(file_name, file_path, regex):
    # print(f"Processing file: {file_path}")
    data = pd.read_csv(file_path)
    match = re.match(regex, file_name)
    if not match:
        # baseline files measure the Matlab project
        # if("-baseline" in file_name):
        #     script_name = file_name
        #     total_energy = sum(compute_core_energy_consumption(data, core) for core in range(TOTAL_NUMBER_CORES + 1))
        #     used_memory = compute_used_memory(COLUMN_MAPPING["used_memory"],data)
        #     time_taken = compute_time_taken(COLUMN_MAPPING["time"], data)
        #     return script_name, total_energy, used_memory, time_taken
        # else:
        print(f"No match for file: {file_path}")
        return None, None, None, None

    script_name = match.group(1)

    # Compute energy consumption for each core
    total_energy = sum(compute_core_energy_consumption(data, core) for core in range(TOTAL_NUMBER_CORES + 1))
    used_memory = compute_used_memory(COLUMN_MAPPING["used_memory"], data)
    time_taken = compute_time_taken(COLUMN_MAPPING["time"], data)

    return script_name, total_energy, used_memory, time_taken

def compute_averages(data_dict):
    averages = {}
    for script, values in data_dict.items():
        averages[script] = {
            'original': values['original'] / TOTAL_NUMBER_REPETITIONS if values['original'] else 0,
            'optimized_gpt3': values['optimized_gpt3'] / TOTAL_NUMBER_REPETITIONS if values['optimized_gpt3'] else 0,
            'optimized_gpt4': values['optimized_gpt4'] / TOTAL_NUMBER_REPETITIONS if values['optimized_gpt4'] else 0,
            'optimized_llama': values['optimized_llama'] / TOTAL_NUMBER_REPETITIONS if values['optimized_llama'] else 0,
            'optimized_mixtral': values['optimized_mixtral'] / TOTAL_NUMBER_REPETITIONS if values['optimized_mixtral'] else 0,
            'baseline': values['baseline'] / TOTAL_NUMBER_REPETITIONS if values['baseline'] else 0
        }
    return averages

def main():
    # regex = re.compile('energy_metrics_(.*).m_(\d+).csv')
    regex = re.compile(r'energy_metrics_(.*).m_*\d+\.csv')  # macOS
    #files_output = "../output/"
    files_output = INPUT_FOLDER
    energy_files = [file for file in os.listdir(files_output) if 'energy_metrics_' in file]

    if not energy_files:
        print("No energy files found in the directory")
        return

    energy_consumption_by_script = defaultdict(
        lambda: {'baseline': 0,'original': 0, 'optimized_gpt3': 0, 'optimized_gpt4': 0, 'optimized_llama': 0, 'optimized_mixtral': 0})
    time_taken_by_script = defaultdict(lambda: {'baseline': 0,'original': 0, 'optimized_gpt3': 0, 'optimized_gpt4': 0, 'optimized_llama': 0, 'optimized_mixtral': 0})
    used_memory_by_script = defaultdict(lambda: {'baseline': 0,'original': 0, 'optimized_gpt3': 0, 'optimized_gpt4': 0, 'optimized_llama': 0, 'optimized_mixtral': 0})

    for energy_file in energy_files:
        file_path = os.path.join(files_output, energy_file)
        # print(f"Processing file: {file_path}")
        script_name, total_energy, used_memory, time_taken = process_energy_file(energy_file, file_path, regex)

        if script_name:
            base_name = script_name
            suffix = 'original'

            if "_optimized_gpt4" in script_name:
                base_name = script_name.replace("_optimized_gpt4", "")
                suffix = 'optimized_gpt4'
            elif "_optimized_llama" in script_name:
                base_name = script_name.replace("_optimized_llama", "")
                suffix = 'optimized_llama'
            elif "_optimized_mixtral" in script_name:
                base_name = script_name.replace("_optimized_mixtral", "")
                suffix = 'optimized_mixtral'
            elif "_optimized_gpt3" in script_name:
                base_name = script_name.replace("_optimized_gpt3", "")
                suffix = 'optimized_gpt3'
            elif "_baseline" in script_name:
                base_name = script_name.replace("_baseline", "")
                suffix = 'baseline'


            energy_consumption_by_script[base_name][suffix] += total_energy
            used_memory_by_script[base_name][suffix] += used_memory
            time_taken_by_script[base_name][suffix] += time_taken

            print(f"Updated {base_name} ({suffix}): Energy={total_energy}, Memory={used_memory}, Time={time_taken}")

    avg_energy_per_script = compute_averages(energy_consumption_by_script)
    avg_memory_per_script = compute_averages(used_memory_by_script)
    avg_time_per_script = compute_averages(time_taken_by_script)

    # Convert the averages to DataFrames
    energy_df = pd.DataFrame.from_dict(avg_energy_per_script, orient='index').reset_index().rename(
        columns={'index': 'script_name'})
    memory_df = pd.DataFrame.from_dict(avg_memory_per_script, orient='index').reset_index().rename(
        columns={'index': 'script_name'})
    time_df = pd.DataFrame.from_dict(avg_time_per_script, orient='index').reset_index().rename(
        columns={'index': 'script_name'})

    # Rename the columns for clarity
    energy_df = energy_df.rename(columns={
         'baseline': 'baseline_energy','original': 'original_energy', 'optimized_gpt3': 'optimized_gpt3_energy',
        'optimized_gpt4': 'optimized_gpt4_energy', 'optimized_llama': 'optimized_llama_energy', 'optimized_mixtral': 'optimized_mixtral_energy'
    })
    memory_df = memory_df.rename(columns={
        'baseline': 'baseline_memory','original': 'original_memory', 'optimized_gpt3': 'optimized_gpt3_memory',
        'optimized_gpt4': 'optimized_gpt4_memory', 'optimized_llama': 'optimized_llama_memory', 'optimized_mixtral': 'optimized_mixtral_memory'
    })
    time_df = time_df.rename(columns={
        'baseline': 'baseline_time','original': 'original_time', 'optimized_gpt3': 'optimized_gpt3_time',
        'optimized_gpt4': 'optimized_gpt4_time', 'optimized_llama': 'optimized_llama_time', 'optimized_mixtral': 'optimized_mixtral_time'
    })
    # Merge DataFrames on script_name
    final_df = energy_df.merge(memory_df, on='script_name').merge(time_df,on='script_name')

    # Save the final DataFrame to a CSV file
    results_path = os.path.join(files_output, 'processed_results', 'averages_results.csv')
    print(f"results saved to {results_path}")
    os.makedirs(os.path.dirname(results_path), exist_ok=True)  # Create directories if they do not exist
    final_df.to_csv(results_path, index=False)

    return final_df

if __name__ == "__main__":
    final_results = main()

    print("\nFinal Averages Results:")
    print(final_results)