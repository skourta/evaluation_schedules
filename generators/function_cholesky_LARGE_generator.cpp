#include <tiramisu/tiramisu.h>
#include <tiramisu/auto_scheduler/evaluator.h>
#include <tiramisu/auto_scheduler/search_method.h>
#include "function_cholesky_LARGE_wrapper.h"

using namespace tiramisu;

int main(int argc, char **argv)
{
    tiramisu::init("function_cholesky_LARGE");

    // -------------------------------------------------------
    // Layer I
    // ------------------------------------------------------- 

    //Iteration variables    
    var i("i"), j("j"), k("k"), l("l"), m("m");
    

    //inputs
    input A("A", {i, i}, p_float64);


    //Computations
    computation A_sub("{A_sub[i,j,k]: 0<=i<2000 and 0<=j<i and 0<=k<j}", expr(), true, p_float64, global::get_implicit_function());
    A_sub.set_expression(A(i,j) - A(i,k)*A(j,k));
    computation A_div("{A_div[i,j]: 0<=i<2000 and 0<=j<i}", expr(), true, p_float64, global::get_implicit_function());
    A_div.set_expression(A(i,j)/A(j,j));
    computation A_diag("{A_diag[i,k]: 0<=i<2000 and 0<=k<i}", expr(), true, p_float64, global::get_implicit_function());
    A_diag.set_expression(A(i,i) - A(i,k)*A(i,k));
    computation A_out("{A_out[i]: 0<=i<2000}", expr(), true, p_float64, global::get_implicit_function());
    A_out.set_expression(expr(o_sqrt, A(i,i)));

    
    // -------------------------------------------------------
    // Layer II
    // -------------------------------------------------------
    A_sub.then(A_div,j)
         .then(A_diag, i)
         .then(A_out, i);

    // -------------------------------------------------------
    // Layer III
    // -------------------------------------------------------
    //Input Buffers
    buffer b_A("b_A", {2000,2000}, p_float64, a_output);    

    //Store inputs
    A.store_in(&b_A);    

    //Store computations
    A_sub.store_in(&b_A, {i,j});
    A_div.store_in(&b_A);
    A_diag.store_in(&b_A, {i,i});
    A_out.store_in(&b_A,{i,i});

    // -------------------------------------------------------
    // Code Generation
    // -------------------------------------------------------
    tiramisu::codegen({&b_A}, "function_cholesky_LARGE.o");

    return 0;
}
