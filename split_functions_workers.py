




# add args parser
import argparse
from pathlib import Path


parser = argparse.ArgumentParser(description='Split functions into workers')

parser.add_argument('--benchmarks', type=str, default='benchmarks')
parser.add_argument('--nbr-nodes', type=int, default=1)

args = parser.parse_args()

benchmarks = Path(args.benchmarks)
nbr_nodes = args.nbr_nodes


# for each node create a dir with the functions to be executed by that node

# create the dir for each node and make sure they are empty
for i in range(nbr_nodes):
    node = benchmarks / f'node_{i}'
    node.mkdir(exist_ok=True)
    for f in node.iterdir():
        f.unlink()    

# get the functions
functions = [f for f in benchmarks.iterdir() if f.is_file() and f.name.endswith('.cpp')]
functions.sort()

# copy the functions
for i, f in enumerate(functions):
    Path(benchmarks / f'node_{i % nbr_nodes}' / f.name).write_text(f.read_text())
