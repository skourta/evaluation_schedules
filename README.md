# Batch execute Tiramisu functions

## Usage

Update the environement variables in the script you want to run and execute it.

## Scripts

### `run.sh`

Compiles and runs the Tiramisu functions in the dir passed as argument on the current node. It compiles the generator then compiles and runs the wrapper.

### `run_old.sh`

Compiles and runs the Tiramisu functions in the dir passed as argument on the current node. It compiles the generator then compiles and runs the wrapper. Uses the old Tiramisu compiler.

### `run_node.sh`

Compiles and runs the Tiramisu functions in the dir passed as argument on a node allocated based on the config found inside. It compiles the generator then compiles and runs the wrapper.

### `legality_node.sh`

Compiles and runs the Tiramisu functions in the dir passed as argument without wrappers. Useful for executing legality checks on a node allocated based on the config found inside.

### `evaluate_rl_sbatch.sh`

Takes two arguments, the dir holding the functions to execute and the number of nodes to allocate. It splits the the functions into multiple groups depending on the number of nodes and submits a job for each group. Each job will execute the functions in its group on the allocated node. It compiles the generator then compiles and runs the wrapper.

### `split_functions_workers.py`

Splits the functions in the dir passed as argument into multiple groups depending on the number of nodes passed as argument. It creates a dir for each node inside the dir passed as argument and puts the functions that should be executed on that node inside it.

### `get_results.py`

Extracts the results from the output of the wrapper and puts them in a csv file.