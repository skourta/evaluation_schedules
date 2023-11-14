# check if the user provided the name of the benchmark folder and number of nodes
if [ $# -eq 0 ]; then
    echo "No arguments supplied"
    exit 1
fi

if [ $# -eq 1 ]; then
    echo "Please provide the number of nodes"
    exit 1
fi

python split_functions_workers.py --benchmarks=$1 --nbr-nodes=$2

# launch the nodes in sbatch using the run_node.sh script
for node in $(seq 0 $(($2-1)))
do
    sbatch run_node.sh $1/node_$node
done
