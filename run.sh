TIRAMISU_ROOT=/scratch/sk10691/workspace/tiramisu
CXX=c++
GXX=g++
CC=gcc

LD_LIBRARY_PATH=${TIRAMISU_ROOT}/3rdParty/Halide/build/src:${TIRAMISU_ROOT}/3rdParty/llvm/build/lib:$TIRAMISU_ROOT/3rdParty/isl/build/lib/:

suffix=".cpp"

WORKDIR_DIR="workdir"
RESULTS_DIR="results"

mkdir WORKDIR_DIR
mkdir RESULTS_DIR

for f in ./schedules/*.cpp; do
    # get the function name
    FUNC_NAME=$(basename $f $suffix)

    echo "Running ${FUNC_NAME} ..."

    # copy the files to the WORKDIR_DIR
    cp ./schedules/${FUNC_NAME}.cpp WORKDIR_DIR
    cp ./wrappers/${FUNC_NAME}_wrapper* WORKDIR_DIR

    # go to the WORKDIR_DIR
    cd WORKDIR_DIR

    # compile the generator and run it
    ${CXX} -I${TIRAMISU_ROOT}/3rdParty/Halide/install/include -I${TIRAMISU_ROOT}/include -I${TIRAMISU_ROOT}/3rdParty/isl/include -Wl,--no-as-needed -ldl -g -fno-rtti -lpthread -std=c++17 -O0 -o ${FUNC_NAME}_generator.cpp.o -c ${FUNC_NAME}.cpp

    ${CXX} -Wl,--no-as-needed -ldl -g -fno-rtti -lpthread -std=c++17 -O0 ${FUNC_NAME}_generator.cpp.o -o ./${FUNC_NAME}_generator -L${TIRAMISU_ROOT}/build -L${TIRAMISU_ROOT}/3rdParty/Halide/install/lib64 -L${TIRAMISU_ROOT}/3rdParty/isl/build/lib -Wl,-rpath,${TIRAMISU_ROOT}/build:${TIRAMISU_ROOT}/3rdParty/Halide/install/lib64:${TIRAMISU_ROOT}/3rdParty/isl/build/lib -ltiramisu -ltiramisu_auto_scheduler -lHalide -lisl

    ./${FUNC_NAME}_generator

    # compile the wrapper and run it
    ${CXX} -shared -o ${FUNC_NAME}.o.so ${FUNC_NAME}.o
    ${CXX} -std=c++17 -fno-rtti -I${TIRAMISU_ROOT}/include -I${TIRAMISU_ROOT}/3rdParty/Halide/install/include -I${TIRAMISU_ROOT}/3rdParty/isl/include/ -I${TIRAMISU_ROOT}/benchmarks -L${TIRAMISU_ROOT}/build -L${TIRAMISU_ROOT}/3rdParty/Halide/install/lib64/ -L${TIRAMISU_ROOT}/3rdParty/isl/build/lib -o ${FUNC_NAME}_wrapper -ltiramisu -lHalide -ldl -lpthread -lm -Wl,-rpath,${TIRAMISU_ROOT}/build ./${FUNC_NAME}_wrapper.cpp ./${FUNC_NAME}.o.so -ltiramisu -lHalide -ldl -lpthread -lm -lisl

    ./${FUNC_NAME}_wrapper >../RESULTS_DIR/${FUNC_NAME}.txt

    # clean up the directory
    # rm ./*

    echo "Done running ${FUNC_NAME}!"

    # go back to the parent directory
    cd ..

done
