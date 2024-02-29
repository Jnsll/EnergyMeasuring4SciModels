# Usage

## Sampling

Call most python programs, here, like this `python <script> <YOUR GITHUB LOGIN NAME> <YOUR GITHUB TOKEN>`.
In my case, I run in this order:
- `python sampler.py lanpirot ghp_1dZW...z85mU`
- `python refiner.py lanpirot ghp_1dZW...z85mU`
- `python filter.py`
- `python clone.py lanpirot ghp_1dZW...z85mU`

To not get overwhelmed with too many projects, maybe interrupt `sampler.py` after a while.

## Entry Points

Execute `entryPoints.m`. All possible entrypoint-.m-files will get listed in each project 
in a `entrypoints.csv` file in the project's root directory.
