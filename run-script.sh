docker run --rm -v ./scripts:/scripts -v ./matlab.dat:/licenses/license.lic -e MLM_LICENSE_FILE=/licenses/license.lic mathworks/matlab:r2021b -batch "run('/scripts/candidate_script.m');exit();" 
