import concurrent
import types
from concurrent.futures import ThreadPoolExecutor
import chardet

import os
import subprocess
import time

import openai
import pandas as pd
from tqdm import tqdm
from openai import OpenAI
from mistralai.client import MistralClient
from mistralai.models.chat_completion import ChatMessage
from pydantic import BaseModel, Field

BASIC_PROMPT = """
Optimize the Matlab code for energy efficiency, refactor it and return the refactored code.
Output first Matlab code starting with "```matlab" and ending with "```" and then the reasoning for the optimization.

Code:"{script}"
"""

SYSTEM_PROMPT = """
"You are an expert Matlab developer, specializes in receiving and analyzing user-provided Matlab source code. 
Your primary function is to meticulously review the code, identify potential areas for energy optimization, and directly implement specific optimizations."
"""

# Mapping of model names to the file name style matching
MODEL_FILENAME_MAPPING = {
    'gpt-3.5-turbo': 'optimized_gpt3',
    'gpt-4o': 'optimized_gpt4',
    'mistral-medium' : 'optimized_mistral',
    'mistral-large-latest'  : 'optimized_mistral_large',
    'codestral-latest' : 'optimized_codestral',
     'meta-llama/Meta-Llama-3-70B-Instruct' : 'optimized_llama',
     'mistralai/Mixtral-8x22B-Instruct-v0.1' : 'optimized_mixtral'
}

# Function to get execution time from CSV file
def get_execution_time(csv_path, script_path):
    df = pd.read_csv(csv_path)
    execution_time_row = df.loc[df['script_path'] == script_path]
    if not execution_time_row.empty:
        return execution_time_row['execution_time'].values[0]
    else:
        raise ValueError(f"No execution time found for {script_path} in {csv_path}")


def create_model_directory(output_path, model):
    if model in MODEL_FILENAME_MAPPING:
        # Construct the full path for the new directory
        result_path = os.path.join(output_path, MODEL_FILENAME_MAPPING[model])


        if not os.path.exists(result_path):
            os.makedirs(result_path)
            print(f"Directory created: {result_path}")
        else:
            print(f"Directory already exists: {result_path}")
        return result_path

    else:
        print("Model name not found in the mapping.")
        return output_path

    return result_path

def get_unique_filename(directory, file_name):
    # Check if the file exists and 
    # Generate a unique name if needed as many files have the common names in a project
    file_base_name, file_extension = os.path.splitext(file_name)
    counter = 1
    while os.path.exists(os.path.join(directory, file_name)):
        file_name = f"{file_base_name}_{counter}{file_extension}"
        counter += 1
    return file_name

def detect_encoding(file_path):
    with open(file_path, 'rb') as file:
        detector = chardet.universaldetector.UniversalDetector()
        for line in file:
            detector.feed(line)
            if detector.done:
                break
        detector.close()
    return detector.result['encoding']

# Read MATLAB code from a file
def read_code_from_file(file_path,encoding):
    try:
        with open(file_path, 'r', encoding=encoding) as file:
            code = file.read()
    except UnicodeDecodeError:
        with open(file_path, 'r', encoding='latin1') as file:
            code = file.read()
    return code

# Write MATLAB code to a file
def write_code_to_file(file_path, code, encoding):
    with open(file_path, 'w', encoding=encoding) as file:
        file.write(code)

# Extract MATLAB code and reasoning from the response
def extract_matlab_code_and_reasoning(response):
    response_text = response[0]  # Get the first item from the response list
    code_start = response_text.lower().find("```matlab")
    code_end = response_text.find("```", code_start + 1)
    if code_start == -1 or code_end == -1:
        return response_text, ""
    matlab_code = response_text[code_start + len("```matlab"):code_end].strip()
    reasoning = response_text[:code_start].strip() + response_text[code_end + len("```"):].strip()
    return matlab_code, reasoning

# Define the schema for the output
class Result(BaseModel):
    optimzed_code: str
    reasoning: str

# Fetch and optimize MATLAB code using OpenAI's GPT
def instruct_any_model(client, prompts, model, n=1, temperature=0.5, frequency_penalty=0, presence_penalty=0, with_cache=True, **kwargs):
    max_tokens = 8192

    def construct_req_call(prompt_list):
        messages = [
            {
                "role": "system",
                "content": SYSTEM_PROMPT
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
            ]
        except Exception as e:
            print(f'{model} returned this error: {e}')
            return prompt_list, None

    def fetch_parallel_req(prompt_list):
        inputs = []
        outputs = []
        with ThreadPoolExecutor(max_workers=n) as executor:
            futures = [executor.submit(construct_req_call, prompt) for prompt in prompt_list]
            for future in tqdm(concurrent.futures.as_completed(futures), total=len(prompts), desc="Sending prompts to {model}"):
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


def main_pipeline(client, input_project_folder_path, csv_path, output_path):
    df = pd.read_csv(csv_path)
    optimized_scripts = []
    reasonings = []

    # choose the model
    # model = "gpt-3.5-turbo"
    # model = "gpt-4o"
    # model = "mistral-medium"
    # model = "mistral-large-latest"
    # model = "codestral-latest"
    model = "meta-llama/Meta-Llama-3-70B-Instruct"
    # model = "mistralai/Mixtral-8x22B-Instruct-v0.1"

    for index, row in df.iterrows():
        file_path = os.path.join(input_project_folder_path, row['ScriptPath'].lstrip("/"))
        original_time = row['ExecutionTime']
        print(f"Original Execution Time for {file_path}: {original_time} seconds")

        if not os.path.exists(file_path):
            print(f"File not found: {file_path}")
            continue

        encoding = detect_encoding(file_path)
        print(f'the encoding of the file is: {encoding}')

        # Read original MATLAB code
        original_code = read_code_from_file(file_path,encoding)


        prompt = BASIC_PROMPT.format(script=original_code)
        #prompt = f"Optimize this MATLAB code for better performance:\n\n{original_code}"

        try:
            # Optimize the code using LLM
            optimized_code_list = instruct_any_model(client,[prompt], model= model, n=1, temperature=0.5)
            if optimized_code_list:
                optimized_code, reasoning = extract_matlab_code_and_reasoning(optimized_code_list[0])
            else:
                optimized_code, reasoning = original_code, "No optimization or reasoning provided."

            #optimized_code = optimized_code_list[0] if optimized_code_list else original_code

            # Check if the code was optimized
            if optimized_code and optimized_code != original_code:
                print(f"optimization detected for {file_path}.")

                # Write optimized code to a new file
                file_name = os.path.basename(file_path) # extract the base name or file name
                optimized_file_name = file_name.replace(".m", f"_{MODEL_FILENAME_MAPPING[model]}.m")
                print(f"Optimized file will be named to {optimized_file_name}.")
                #optimized_file_path = file_path.replace(".m", optimized_file_name) #Uncomment this to save the files in their original project folder

                result_path = create_model_directory(output_path,model)

                optimized_file_name = get_unique_filename(result_path, optimized_file_name)
                optimized_file_path = os.path.join(result_path,optimized_file_name)
                print(f"Optimized file will be saved to {optimized_file_path}.")

                write_code_to_file(optimized_file_path, optimized_code, encoding)
                reasonings.append({'OriginalScriptPath':file_path,'OptimizedScriptPath': optimized_file_path, 'Original_code':original_code,'optimized_code': optimized_code,'Reasoning': reasoning})

            else:
                print(f"No optimization or change detected for {file_path}.")
                reasonings.append({'OriginalScriptPath': file_path, 'OptimizedScriptPath': "NA",
                                   'Original_code': original_code, 'optimized_code': "NA",
                                   'Reasoning': reasoning})

        except Exception as e:
            print(e)

        # Save the optimized scripts and their execution times to a new CSV file
        optimized_df = pd.DataFrame(optimized_scripts)
        result_path = create_model_directory(output_path, model)
        output_csv_path = os.path.join(result_path, "OptimizedMatlabScripts.csv")
        optimized_df.to_csv(output_csv_path, index=False)
        print(f"Optimized script details saved to {output_csv_path}")

        # Save the reasonings to a new CSV file
        reasoning_df = pd.DataFrame(reasonings)
        reasoning_csv_path = output_csv_path.replace(".csv", "_reasonings.csv")
        reasoning_df.to_csv(reasoning_csv_path, index=False)
        print(f"Reasoning saved to {reasoning_csv_path}")

def load_api_key():
    api_key = os.getenv("Anyscale_Matlab_Project_key")
    #print(f"Loaded API Key: {api_key}")
    #if not api_key:
    #   raise ValueError("The OpenAI API key must be set as an environment variable 'OPENAI_API_KEY'")
    return  api_key

def load_client(api_key):
    return openai.OpenAI(
        base_url="https://api.endpoints.anyscale.com/v1",
        api_key=api_key)

# Example usage
if __name__ == "__main__":
    # Load your API key from an environment variable or secret management service
    api_key = load_api_key()
    client = load_client(api_key)
    resource_folder = "./../resource/"
    input_project_folder_path = "./../resource/sampling/repos_projects_filtered_top100stars/"
    input_csv_path = os.path.join(resource_folder, "entrypoints_no_crashes_only.csv")  # Path to the CSV file containing execution times
    output_path = os.path.join(resource_folder, "Optimzation_results")  # Output CSV file path
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    else:
        print(f"Directory already exists: {output_path}")

    main_pipeline(client, input_project_folder_path, input_csv_path, output_path)