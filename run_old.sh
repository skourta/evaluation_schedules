# check if the user provided the name of the benchmark folder
if [ $# -eq 0 ]; then
    echo "No arguments supplied"
    exit 1
fi

TIRAMISU_ROOT=/scratch/sk10691/workspace/old_tiramisu
CXX=c++
GXX=g++
CC=gcc

LD_LIBRARY_PATH=${TIRAMISU_ROOT}/3rdParty/Halide/build/src:${TIRAMISU_ROOT}/3rdParty/llvm/build/lib:${TIRAMISU_ROOT}/build:${TIRAMISU_ROOT}/3rdParty/isl/build/lib

suffix=".cpp"

BENCHMARKS_PATH=$1

# if the user provided the name of the benchmark folder as "generators" set suffix to _generator.cpp
if [ $BENCHMARKS_PATH = "generators" ]; then
    suffix="_generator.cpp"
fi

WORKDIR_DIR="workdir_${BENCHMARKS_PATH}"
RESULTS_DIR="results_${BENCHMARKS_PATH}"

mkdir $WORKDIR_DIR
mkdir $RESULTS_DIR

for f in $BENCHMARKS_PATH/*.cpp; do
    # get the function name
    FUNC_NAME=$(basename $f $suffix)

    echo "Running ${FUNC_NAME} ..."

    # copy the files to the WORKDIR_DIR
    cp ./$BENCHMARKS_PATH/${FUNC_NAME}${suffix} $WORKDIR_DIR
    cp ./wrappers/${FUNC_NAME}_wrapper* $WORKDIR_DIR

    # go to the WORKDIR_DIR
    cd $WORKDIR_DIR

    # compile the generator and run it
    ${CXX} -I${TIRAMISU_ROOT}/3rdParty/Halide/include -I${TIRAMISU_ROOT}/include -I${TIRAMISU_ROOT}/3rdParty/isl/include -Wl,--no-as-needed -ldl -g -fno-rtti -lpthread -std=c++11 -O0 -o ${FUNC_NAME}_generator.cpp.o -c ${FUNC_NAME}${suffix}

    ${CXX} -Wl,--no-as-needed -ldl -g -fno-rtti -lpthread -std=c++11 -O0 ${FUNC_NAME}_generator.cpp.o -o ./${FUNC_NAME}_generator -L${TIRAMISU_ROOT}/build -L${TIRAMISU_ROOT}/3rdParty/Halide/lib -L${TIRAMISU_ROOT}/3rdParty/isl/build/lib -Wl,-rpath,${TIRAMISU_ROOT}/build:${TIRAMISU_ROOT}/3rdParty/Halide/lib:${TIRAMISU_ROOT}/3rdParty/isl/build/lib -ltiramisu -ltiramisu_auto_scheduler -lHalide -lisl

    ./${FUNC_NAME}_generator

    # compile the wrapper and run it
    ${CXX} -shared -o ${FUNC_NAME}.o.so ${FUNC_NAME}.o
    ${CXX} -std=c++11 -fno-rtti -I${TIRAMISU_ROOT}/include -I${TIRAMISU_ROOT}/3rdParty/Halide/include -I${TIRAMISU_ROOT}/3rdParty/isl/include/ -I${TIRAMISU_ROOT}/benchmarks -L${TIRAMISU_ROOT}/build -L${TIRAMISU_ROOT}/3rdParty/Halide/lib/ -L${TIRAMISU_ROOT}/3rdParty/isl/build/lib -o ${FUNC_NAME}_wrapper -ltiramisu -lHalide -ldl -lpthread -lm -Wl,-rpath,${TIRAMISU_ROOT}/build ./${FUNC_NAME}_wrapper.cpp ./${FUNC_NAME}.o.so -ltiramisu -lHalide -ldl -lpthread -lm -lisl

    ./${FUNC_NAME}_wrapper >../$RESULTS_DIR/${FUNC_NAME}.txt

    # remove the files from the WORKDIR_DIR
    rm -rf ${FUNC_NAME}_generator.cpp.o
    rm -rf ${FUNC_NAME}_generator
    rm -rf ${FUNC_NAME}.o
    rm -rf ${FUNC_NAME}.o.so
    rm -rf ${FUNC_NAME}_wrapper

    printf "Done running ${FUNC_NAME}! Remaining: $(ls ../$RESULTS_DIR | wc -l)/$(ls ../$BENCHMARKS_PATH | wc -l)\n\n"

    # go back to the parent directory
    cd ..
done

rm -rf $WORKDIR_DIR

python get_results.py --schedules=$BENCHMARKS_PATH
