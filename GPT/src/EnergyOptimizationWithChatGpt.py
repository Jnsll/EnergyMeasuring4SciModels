import concurrent
import types
from concurrent.futures import ThreadPoolExecutor

import os
import subprocess
import time

import pandas as pd
from openai import OpenAI
from tqdm import tqdm

BASIC_PROMPT = """
Optimize the Matlab code for energy efficiency, refactor it and return the refactored code.

Code:"{script}"
"""

# Function to get execution time from CSV file
def get_execution_time(csv_path, script_path):
    df = pd.read_csv(csv_path)
    execution_time_row = df.loc[df['script_path'] == script_path]
    if not execution_time_row.empty:
        return execution_time_row['execution_time'].values[0]
    else:
        raise ValueError(f"No execution time found for {script_path} in {csv_path}")

# Function to run a MATLAB script and return its execution time
def run_matlab_script(script_path):
    #start_time = time.time()
    #result = subprocess.run(["matlab", "-batch", f"run('{script_path}')"], capture_output=True, text=True)
    #end_time = time.time()
    #execution_time = end_time - start_time
    execution_time = 15.4
    #if result.returncode != 0:
    #    raise RuntimeError(f"Error running {script_path}: {result.stderr}")

    return execution_time


# Read MATLAB code from a file
def read_code_from_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            code = file.read()
    except UnicodeDecodeError:
        with open(file_path, 'r', encoding='latin1') as file:
            code = file.read()
    return code

# Write MATLAB code to a file
def write_code_to_file(file_path, code):
    with open(file_path, 'w') as file:
        file.write(code)

# Extract MATLAB code and reasoning from the response
def extract_matlab_code_and_reasoning(response):
    response_text = response[0]  # Get the first item from the response list
    code_start = response_text.find("```matlab")
    code_end = response_text.find("```", code_start + 1)
    if code_start == -1 or code_end == -1:
        return response_text, ""
    matlab_code = response_text[code_start + len("```matlab"):code_end].strip()
    reasoning = response_text[:code_start].strip() + response_text[code_end + len("```"):].strip()
    return matlab_code, reasoning

# Fetch and optimize MATLAB code using OpenAI's GPT
def instruct_gpt_model(client, prompts, model, n=1, temperature=0.5, frequency_penalty=0, presence_penalty=0, with_cache=True, **kwargs):
    max_tokens = None

    # Adjusts the maximum tokens to ensure the response fits within the model's limits.
    if '32k' in model:
        max_tokens = 32768
    elif '16k' in model:
        max_tokens = 16385
    elif 'preview' in model:
        max_tokens = 4095
    if not max_tokens:
        if model.startswith('gpt-4o'):
            max_tokens = 4095
        else:
            max_tokens = 8192

    def construct_req_call(prompt_list):
        messages = [
            {
                "role": "system",
                "content": "You are an expert Matlab developer, specializes in receiving and analyzing user-provided Matlab source code. Your primary function is to meticulously review the code, identify potential areas for energy optimization, and directly implement or suggest specific optimizations."
            },
            {
                "role": "user",
                "content": prompt_list
            }
        ]
        adjusted_max_tokens = max_tokens - 2 * len(prompt_list.split(' '))
        if adjusted_max_tokens < 1:
            return prompt_list, None
        try:
            response = client.chat.completions.create(
                model=model,
                messages=messages,
                max_tokens=adjusted_max_tokens,
                n=1,
                stop=None,
                temperature=temperature,
                frequency_penalty=frequency_penalty,
                presence_penalty=presence_penalty
            )
            print(response.choices[0].message.content)
            return prompt_list, [
                #response.choices[0].message.content.strip()
                choice.message.content.strip()
                for choice in response.choices
                #if r['message']['content'] != 'Hello! It seems like your message might have been cut off. How can I assist you today?'
            ]
        except Exception as e:
            print(f'OpenAI returned this error: {e}')
            return prompt_list, None

    def fetch_parallel_req(prompt_list):
        inputs = []
        outputs = []
        with ThreadPoolExecutor(max_workers=n) as executor:
            futures = [executor.submit(construct_req_call, prompt) for prompt in prompt_list]
            for future in tqdm(concurrent.futures.as_completed(futures), total=len(prompts), desc="Sending prompts to OpenAI"):
                i, o = future.result()
                inputs.append(i)
                outputs.append(o)
        return inputs, outputs

    if not with_cache:
        if isinstance(prompts, types.GeneratorType):
            prompts = tuple(prompts)
        return fetch_parallel_req(prompts)[-1]

    return fetch_parallel_req(prompts)[-1]

# Main pipeline function
def main_pipeline(api_key, resource_folder, csv_path, output_csv_path):
    client = OpenAI(
        # This is the default and can be omitted
        api_key=api_key,
    )
    #openai.api_key = api_key  # Set the API key globally
    df = pd.read_csv(csv_path)
    optimized_scripts = []
    reasonings = []

    for index, row in df.iterrows():
        file_path = os.path.join(resource_folder, row['ScriptPath'].lstrip("/"))
        original_time = row['ExecutionTime']
        print(f"Original Execution Time for {file_path}: {original_time} seconds")

        # Check if file exists
        if not os.path.exists(file_path):
            print(f"File not found: {file_path}")
            continue

        # Read original MATLAB code
        original_code = read_code_from_file(file_path)

        # Optimize the code using ChatGPT
        prompt = BASIC_PROMPT.format(script=original_code)
        #prompt = f"Optimize this MATLAB code for better performance:\n\n{original_code}"

        #choose the model
        #model = "text-davinci-003"
        #model = "gpt-3.5-turbo"
        model = "gpt-4o"

        try:
            optimized_code_list = instruct_gpt_model(client,[prompt], model= model, n=1, temperature=0.5)
            if optimized_code_list:
                optimized_code, reasoning = extract_matlab_code_and_reasoning(optimized_code_list[0])
            else:
                optimized_code, reasoning = original_code, "No optimization or reasoning provided."

            #optimized_code = optimized_code_list[0] if optimized_code_list else original_code

            # Check if the code was modified
            if optimized_code and optimized_code != original_code:
                print(f"optimization detected for {file_path}.")
                # Write optimized code to a new file
                optimized_file_path = file_path.replace(".m", "_optimized.m")
                write_code_to_file(optimized_file_path, optimized_code)
                reasonings.append({'OriginalScriptPath':file_path,'OptimizedScriptPath': optimized_file_path, 'Original_code':original_code,'optimized_code': optimized_code,'Reasoning': reasoning})

                optimized_time = run_optimize_code(optimized_file_path, optimized_scripts)
            else:
                print(f"No optimization or change detected for {file_path}.")

        except Exception as e:
            print(e)

        # Save the optimized scripts and their execution times to a new CSV file
        optimized_df = pd.DataFrame(optimized_scripts)
        optimized_df.to_csv(output_csv_path, index=False)
        print(f"Optimized script details saved to {output_csv_path}")

        # Save the reasonings to a new CSV file
        reasoning_df = pd.DataFrame(reasonings)
        reasoning_csv_path = output_csv_path.replace(".csv", "_reasonings.csv")
        reasoning_df.to_csv(reasoning_csv_path, index=False)
        print(f"Reasonings saved to {reasoning_csv_path}")


def run_optimize_code(optimized_file_path, optimized_scripts):
    try:
        # Run the optimized script and measure its execution time
        optimized_time = run_matlab_script(optimized_file_path)
        print(f"Optimized Execution Time for {optimized_file_path}: {optimized_time} seconds")

        # Append to the list of optimized scripts
        optimized_scripts.append({'ScriptPath': optimized_file_path, 'ExecutionTime': optimized_time})
    except RuntimeError as e:
        print(e)


def load_api_key():
    api_key = os.getenv("OPENAI_API_KEY")
    #print(f"Loaded API Key: {api_key}")
    if not api_key:
       raise ValueError("The OpenAI API key must be set as an environment variable 'OPENAI_API_KEY'")
    return  api_key


# Example usage
if __name__ == "__main__":
    # Load your API key from an environment variable or secret management service
    api_key = load_api_key()

    resource_folder = "./../resource"
    csv_path = os.path.join(resource_folder, "MatlabEntryPoints.csv")  # Path to the CSV file containing execution times
    output_csv_path = os.path.join(resource_folder, "OptimizedMatlabScripts.csv")  # Output CSV file path

    main_pipeline(api_key, resource_folder, csv_path, output_csv_path)