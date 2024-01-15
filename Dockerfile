FROM mathworks/matlab:r2021b


#COPY ./src /energyscipipelines
COPY $SCRIPT script.m
COPY ./EnergiBridge ./
COPY ./output ./

# Default folder

ENTRYPOINT /home/tdurieux/git/EnergiBridge/target/release/energibridge --summary --output output/energy_metrics_docker.csv -c output/output_simulation.txt matlab -nodisplay -nosplash -nodesktop -r "run('/energyscipipelines/script.m');exit();"