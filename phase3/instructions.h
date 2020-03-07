#ifndef MINI_L_INSTRUCTIONS
#define MINI_L_INSTRUCTIONS

#include <string>

std::string gen_ins_param(std::string const & src);
std::string gen_ins_call(std::string const & src, 
                         std::string const & dst);
std::string gen_ins_ret(std::string const & src);
std::string gen_ins_declare_variable(std::string const & src);
std::string gen_ins_declare_variable(std::string const & src, 
                                     std::string const & size);
std::string gen_ins_copy(std::string const & dst, 
                         std::string const src);
std::string gen_ins_array_access_rval(std::string const & dst, 
                                      std::string const & src, 
                                      std::string const & idx);
std::string gen_ins_array_access_lval(std::string const & dst, 
                                      std::string const & idx, 
                                      std::string const & src);
std::string gen_ins_read_in(std::string const & dst);
std::string gen_ins_read_in(std::string const & dst, 
                            std::string const & idx);
std::string gen_ins_write_out(std::string const & src);
std::string gen_ins_write_out(std::string const & src, 
                              std::string const & idx);
std::string gen_ins_tac(std::string const & op_code, 
                        std::string const & dst, 
                        std::string const & src1, 
                        std::string const & src2);
std::string gen_ins_arithmetic(std::string const & op_code, 
                               std::string const & dst, 
                               std::string const & src1, 
                               std::string const & src2);
std::string gen_ins_comparison(std::string const & op_code, 
                               std::string const & dst, 
                               std::string const & src1, 
                               std::string const & src2);
std::string gen_ins_logical_or(std::string const & dst, 
                               std::string const & src1, 
                               std::string const & src2);
std::string gen_ins_logical_and(std::string const & dst, 
                                std::string const & src1, 
                                std::string const & src2);
std::string gen_ins_logical_not(std::string const & dst, 
                                std::string const & src);
std::string gen_ins_declare_label(std::string const & lbl);
std::string gen_ins_branch_goto(std::string const & lbl);
std::string gen_ins_branch_conditional(std::string const & lbl, 
                                       std::string const & pred);

#endif  // MINI_L_INSTRUCTIONS
