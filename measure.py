import subprocess
import sys
import pandas as pd


scripts_to_run_df = pd.read_csv('sci_script.csv')
for ind in scripts_to_run_df.index:
    sci_script = scripts_to_run_df['Paths'][ind]

    script_command = ["/home/tdurieux/git/EnergiBridge/target/release/energibridge" ,"--summary" ,"--output", "./output/energy_metrics.csv" ,"-c" ,"./output/output_simulation.txt" ,"docker" ,"run", "--rm", "-v", "./scripts:/scripts" ,"-v" ,"./matlab.dat:/licenses/license.lic", "-e", "MLM_LICENSE_FILE=/licenses/license.lic", "mathworks/matlab:r2021b" ,"-batch", "run('" + str(sci_script) + "');exit();"]

    result = subprocess.run(script_command)
