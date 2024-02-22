%% Entry Points Script
function entryPoints(path)

projectFolder = path;
prj = matlab.project.createProject("Folder", projectFolder, "Name", "NewProject");

items = what(projectFolder);
for idx = 1:numel(items.m)
  prj.addFile(items.m{idx})
end

% get current project
prj = currentProject;

% update dependencies
prj.updateDependencies

% get dependency digraph
dependencyGraph = prj.Dependencies;

% get edges of dependency graph
edges = dependencyGraph.Edges;

% get file names (without full path)
edges.EndNodes(:,1) = regexpi(edges.EndNodes(:,1),'\w*\.\w*','match','once');
edges.EndNodes(:,2) = regexpi(edges.EndNodes(:,2),'\w*\.\w*','match','once');

% files that call other files
callingFiles = unique(edges.EndNodes(:,1));
% files that are called by other files
calledFiles = unique(edges.EndNodes(:,2));

% files that are either entry points or unused files
entryPoints = setdiff(callingFiles,calledFiles);
