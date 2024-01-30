import subprocess
import sys

script_command = ["/home/tdurieux/git/EnergiBridge/target/release/energibridge" ,"--summary" ,"--output", "./output/energy_metrics.csv" ,"-c" ,"./output/output_simulation.txt" ,"docker" ,"run", "--rm", "-v", "./scripts:/scripts" ,"-v" ,"./matlab.dat:/licenses/license.lic", "-e", "MLM_LICENSE_FILE=/licenses/license.lic", "mathworks/matlab:r2021b" ,"-batch", "run('/scripts/candidate_script.m');exit();"]

result = subprocess.run(script_command)
