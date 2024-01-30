FROM mathworks/matlab:r2021b


#COPY ./src /energyscipipelines
COPY ./scripts/candidate_script.m /scripts/candidate_script.m

# Default folder

#CMD ["matlab", "-batch", "/home/exps/candidate_script.m"]

#/home/tdurieux/git/EnergiBridge/target/release/energibridge --summary --output output/energy_metrics_docker.csv -c output/output_simulation.txt matlab -nodisplay -nosplash -nodesktop -r "run('/energyscipipelines/script.m');exit();" 
