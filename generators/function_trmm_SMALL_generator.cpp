#include <tiramisu/tiramisu.h>
#include <tiramisu/auto_scheduler/evaluator.h>
#include <tiramisu/auto_scheduler/search_method.h>
#include "function_trmm_SMALL_wrapper.h"

using namespace tiramisu;


int main(int argc, char **argv)
{
    tiramisu::init("function_trmm_SMALL");

    // -------------------------------------------------------
    // Layer I
    // ------------------------------------------------------- 
    constant NN("NN", 80);
    constant MM("MM", 60);

    //Iteration variables    
//     var i("i", 0, 60), j("j", 0, 80), k("k", 0, 60);
    var i("i", 0, 60), j("j", 0, 80), k("k");
    

    //inputs
    input A("A", {i, k}, p_float64);
    input B("B", {i, j}, p_float64);


    //Computations
    computation AB("{AB[i,j,k]: 0<=i<60 and 0<=j<80 and i+1<=k<60}", expr(), true, p_float64, global::get_implicit_function());
    AB.set_expression(B(i,j) + A(k,i)*B(k,j));
    computation B_out("{B_out[i,j]: 0<=i<60 and 0<=j<80}", expr(), true, p_float64, global::get_implicit_function());
    B_out.set_expression(B(i,j)*1.5);

    
    // -------------------------------------------------------
    // Layer II
    // -------------------------------------------------------
    AB.then(B_out, j);

    // -------------------------------------------------------
    // Layer III
    // -------------------------------------------------------
    //Input Buffers
    buffer b_A("b_A", {60,60}, p_float64, a_input);
    buffer b_B("b_B", {60,80}, p_float64, a_output);
    

    //Store inputs
    A.store_in(&b_A);
    B.store_in(&b_B);
    

    //Store computations
    AB.store_in(&b_B, {i,j});
    B_out.store_in(&b_B);

    // -------------------------------------------------------
    // Code Generation
    // -------------------------------------------------------
    tiramisu::codegen({&b_A, &b_B}, "function_trmm_SMALL.o");

    return 0;
}
