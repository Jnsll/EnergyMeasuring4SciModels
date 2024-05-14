# EnergyMeasuring4SciModels

# About The Project
The aim of this project is to make a first step towards measuring energy efficiency in scientific workflows. We explore the scientific software systems developed in Matlab, which is heavily used in academia and industry. We establish an automated pipeline to measure the energy footprint of a large set of projects mined from Github. We provide the pipeline and the dataset here so that other researchers can replicate our results.


# Getting Started



## Prerequisites

The tool EnergiBridge should be installed on the running environment.
Link: https://github.com/tdurieux/EnergiBridge

## Installation

Clone the repo
```git clone https://github.com/Jnsll/EnergyMeasuring4SciModels.git```

Building Docker Image for Experiments
In the root of the project: ```docker build -f Dockerfile.toolbox -t matlab-r2021b-toolbox .```

Set the path to the location of the EnergiBridge tool in the ```experimentation/measure.py``` file, in the following code line:

```script_command = ["/home/tdurieux/git/EnergiBridge/target/release/energibridge" ,"--summary" ,"--output", ...]```


# Usage

## Mining
TODO

## Preprocessing

## Experimentation
In folder experimentation: ```python3 measure.py -f <path_to_scripts_to_run> -rep <number_repetition>```

Example: ```python3 measure.py -f Entrypoints_files_no_crashes_sample.csv -rep 2```


## Structure of the project

.
├── Dockerfile.toolbox
├── LICENSE
├── README.md
├── experimentation
│   ├── Entrypoints_files_no_crashes_sample.csv
│   ├── __init__.py
│   └── measure.py
├── helpers
│   ├── Projects_Time_Study_no_crashes_sample_demo.csv
│   ├── extract_path_project.py
│   ├── extract_toolboxes_names.py
│   └── products.txt
├── matlab_energy_analysis
│   ├── README.md
│   ├── entryPoints.m
│   ├── entrypoints.csv
│   └── entrypoints_no_crashes_only.csv
├── output
│   ├── energy_metrics.csv
│   └── executions_order.csv
└── tests
    ├── __init__.py
    └── test_measure.py



