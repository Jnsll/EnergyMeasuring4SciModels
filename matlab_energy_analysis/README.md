## Entry Points

Execute `entryPoints.m`. All possible entrypoint-.m-files will get listed in each project in a `entrypoints.csv` file in the project's root directory. If the script runs through (without crashes), then an overall `entrypoints.csv` file will also be created, here. This overall file lists all entrypoints of all analyzed projects. 

Typically, some .m-files, we analyze do not finish (e.g. waiting for keyboard input), restart the `entryPoints.m` script when you get stuck. Such .m-files won't be analyzed twice.

If you want to use the entryPoints-script to determine entry points in your subfolder myDirectory, start 
the script like this: `entryPoints.m(<myDirectory>)`.
