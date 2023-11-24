#include <tiramisu/tiramisu.h>
#include <tiramisu/auto_scheduler/evaluator.h>
#include <tiramisu/auto_scheduler/search_method.h>
#include "function_jacobi2d_MEDIUM_wrapper.h"

using namespace tiramisu;


int main(int argc, char **argv)
{
    tiramisu::init("function_jacobi2d_MEDIUM");

    // -------------------------------------------------------
    // Layer I
    // ------------------------------------------------------- 

    //Iteration variables    
    var i_f("i_f", 0, 250), j_f("j_f", 0, 250);
    var t("t", 0, 100), i("i", 1, 250-1), j("j", 1, 250-1);
    
    //inputs
    input A("A", {i_f, j_f}, p_float64);
    input B("B", {i_f, j_f}, p_float64);

    //Computations
    computation B_comp("B_comp", {t,i,j}, (A(i, j) + A(i, j-1) + A(i, 1+j) + A(1+i, j) + A(i-1, j))*0.2);
    computation A_comp("A_comp", {t,i,j}, (B(i, j) + B(i, j-1) + B(i, 1+j) + B(1+i, j) + B(i-1, j))*0.2);

    //Ordering
    B_comp.then(A_comp,t);

    //Input Buffers
    buffer b_A("b_A", {250,250}, p_float64, a_output);    
    buffer b_B("b_B", {250,250}, p_float64, a_output);

    //Store inputs
    A.store_in(&b_A);
    B.store_in(&b_B);


    //Store computations
    B_comp.store_in(&b_B, {i,j});
    A_comp.store_in(&b_A, {i,j});

    // -------------------------------------------------------
    // Code Generation
    // -------------------------------------------------------
    tiramisu::codegen({&b_A,&b_B}, "function_jacobi2d_MEDIUM.o");

    return 0;
}