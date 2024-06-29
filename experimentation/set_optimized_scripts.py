import csv
import re
import shutil
from pathlib import Path

regex_origin = re.compile('./../resource(.*/)(.*m)')
regex_optimized = re.compile('./../resource(.*m)')

with open("../GPT/resource/Optimzation_results/optimized_gpt3/OptimizedMatlabScripts_reasonings.csv", "r") as csvfile: 
    reader_variable = csv.reader(csvfile)
    for row in reader_variable:
        origin_script = row[0]
        optimized_script = row[1]
        #print(origin_script)
        p = re.match(regex_origin, origin_script)
        p_optimized = re.match(regex_optimized, optimized_script)
        if p:
            path_to_original_script = p.group(1)
            name_original_script = p.group(2)
            #print("Orginial script:", path_to_original_script, name_original_script)
        if p_optimized:
            optimized_script = p_optimized.group(1)
            #print("optimized:", optimized_script)
        try:
            #3print("../GPT/resource" + str(optimized_script))
            #print(Path(".." + str(path_to_original_script) + "/") )
            if p:
                print("../GPT/resource" + str(optimized_script), ".." + str(path_to_original_script))
                shutil.copy("../GPT/resource" + str(optimized_script), ".." + str(path_to_original_script))
                     
        except:
        #    print("Error with the file copy!")
             
            #print(path_to_original_script, name_original_script)
            #print("optimized:", optimized_script)
            print("error")



    

#    print(second)
    
    
#    for row in reader_variable:
#        print(row[0])


