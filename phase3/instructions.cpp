#include "instructions.h"

std::string 
gen_ins_param(std::string const & src)
// returns a string of the form "param src\n"
{
  static std::string const INS_PARAM = "param";
  std::string ret;
  ret += INS_PARAM;
  ret += ' ';
  ret += src;
  ret += '\n';
  return ret;
}

std::string 
gen_ins_call(std::string const & src, 
             std::string const & dst)
// returns a string of the form "call src, dst\n"
{
  static std::string const INS_CALL = "call";
  std::string ret;
  ret += INS_CALL;
  ret += ' ';
  ret += src;
  ret += ',';
  ret += ' ';
  ret += dst;
  ret += '\n';
  return ret;
}

std::string 
gen_ins_ret(std::string const & src)
// returns a string of the form "ret src\n"
{
  static std::string const INS_RET = "ret";
  std::string ret;
  ret += INS_RET;
  ret += ' ';
  ret += src;
  ret += '\n';
  return ret; 
}

std::string 
gen_ins_declare_variable(std::string const & src)
// returns a string of the form ". src\n"
{
  static std::string const INS_DECLARE_SCALAR = ".";
  std::string ret;
  ret += INS_DECLARE_SCALAR;
  ret += ' ';
  ret += src;
  ret += '\n';
  return ret;
}

std::string 
gen_ins_declare_variable(std::string const & src, 
                         std::string const & size)
// returns a string of the form ".[] name, size\n".
{
  static std::string const INS_DECLARE_ARR = ".[]";
  std::string ret;
  ret += INS_DECLARE_ARR;
  ret += ' ';
  ret += src;
  ret += ',';
  ret += ' ';
  ret += size;
  ret += '\n';
  return ret;
}

std::string 
gen_ins_copy(std::string const & dst, 
             std::string const src)
// returns a string of the form "= dst, src\n"
// where src can be an immediate
{
  static std::string const INS_COPY = "=";
  std::string ret;
  ret += INS_COPY;
  ret += ' ';
  ret += dst;
  ret += ',';
  ret += ' ';
  ret += src;
  ret += '\n';
  return ret;
}

std::string 
gen_ins_array_access_rval(std::string const & dst, 
                          std::string const & src, 
                          std::string const & idx)
// returns a string of the form "=[] dst, src, idx"
// where idx can be an immediate. Implements translation
// of the statement dst = src[idx].
{
  static std::string const INS_ARR_RVAL = "=[]";
  std::string ret;
  ret += INS_ARR_RVAL;
  ret += ' ';
  ret += dst;
  ret += ',';
  ret += ' ';
  ret += src;
  ret += ',';
  ret += ' ';
  ret += idx;
  ret += '\n';
  return ret;
}

std::string 
gen_ins_array_access_lval(std::string const & dst, 
                          std::string const & idx, 
                          std::string const & src)
// returns a string of the form "[]= dst, idx, src"
// where idx and src can be immediates. Implements 
// translation of the statement dst[idx] = src.
{
  static std::string const INS_ARR_LVAL = "[]=";
  std::string ret;
  ret += INS_ARR_LVAL;
  ret += ' ';
  ret += dst;
  ret += ',';
  ret += ' ';
  ret += idx;
  ret += ',';
  ret += ' ';
  ret += src;
  ret += '\n';
  return ret;
}

std::string 
gen_ins_read_in(std::string const & dst)
// returns a string of the form ".< dst\n"
{
  static std::string const INS_READ_SCALAR = ".<";
  std::string ret;
  ret += INS_READ_SCALAR;
  ret += ' ';
  ret += dst;
  ret += '\n';
  return ret;
}

std::string 
gen_ins_read_in(std::string const & dst, 
                std::string const & idx)
// returns a string of the form ".[]< dst, idx\n"
{
  static std::string const INS_READ_ARR = ".[]<";
  std::string ret;
  ret += INS_READ_ARR;
  ret += ' ';
  ret += dst;
  ret += ',';
  ret += ' ';
  ret += idx;
  ret += '\n';
  return ret;
}

std::string 
gen_ins_write_out(std::string const & src)
// returns a string of the form ".> src\n"
{
  static std::string const INS_WRITE_OUT_SCALAR = ".>";
  std::string ret;
  ret += INS_WRITE_OUT_SCALAR;
  ret += ' ';
  ret += src;
  ret += '\n';
  return ret;
}

std::string 
gen_ins_write_out(std::string const & src, 
                  std::string const & idx)
// returns a string of the form ".[]> src, idx\n"
{
  static std::string const INS_WRITE_OUT_ARR = ".[]>";
  std::string ret;
  ret += INS_WRITE_OUT_ARR;
  ret += ' ';
  ret += src;
  ret += ',';
  ret += ' ';
  ret += idx;
  ret += '\n';
  return ret;
}

std::string 
gen_ins_tac(std::string const & op_code, 
            std::string const & dst, 
            std::string const & src1, 
            std::string const & src2)
// returns three address code as a string of 
// the form "op_code dst, src1, src2\n". One
// or both source operands can be immediates.
{
  std::string ret; 
  ret += op_code;
  ret += ' ';
  ret += dst;
  ret += ',';
  ret += ' ';
  ret += src1;
  ret += ',';
  ret += ' ';
  ret += src2;
  ret += '\n';
  return ret;
}

std::string 
gen_ins_arithmetic(std::string const & op_code, 
                   std::string const & dst, 
                   std::string const & src1, 
                   std::string const & src2)
{
  return gen_ins_tac(op_code, dst, src1, src2);
}

std::string 
gen_ins_comparison(std::string const & op_code, 
                   std::string const & dst, 
                   std::string const & src1, 
                   std::string const & src2)

{
  return gen_ins_tac(op_code, dst, src1, src2);
}

std::string 
gen_ins_logical_or(std::string const & dst, 
                   std::string const & src1, 
                   std::string const & src2)
{
  return gen_ins_tac("||", dst, src1, src2);
}


std::string 
gen_ins_logical_and(std::string const & dst, 
                    std::string const & src1, 
                    std::string const & src2)
{
  return gen_ins_tac("&&", dst, src1, src2);
}

std::string 
gen_ins_logical_not(std::string const & dst, 
                    std::string const & src)
// returns a string of the form "! dst, src\n"
{
  static std::string const INS_LOGICAL_NOT = "!";
  std::string ret;
  ret += INS_LOGICAL_NOT;
  ret += ' ';
  ret += dst;
  ret += ',';
  ret += ' ';
  ret += src;
  ret += '\n';
  return ret;
}

std::string 
gen_ins_declare_label(std::string const & lbl)
// returns a string of the form ": lbl\n"
{
  static std::string const INS_LABEL = ":";
  std::string ret;
  ret += INS_LABEL;
  ret += ' ';
  ret += lbl;
  ret += '\n';
  return ret;
}

std::string 
gen_ins_branch_goto(std::string const & lbl)
// returns a string of the form ":= label\n"
{
  static std::string const INS_BRANCH_GOTO = ":=";
  std::string ret;
  ret += INS_BRANCH_GOTO;
  ret += ' ';
  ret += lbl;
  ret += '\n';
  return ret;
}

std::string 
gen_ins_branch_conditional(std::string const & lbl,
                           std::string const & pred)
// returns a string of the form "?:= label, pred"
{
  static std::string const INS_BRANCH_CONDITIONAL = "?:=";
  std::string ret;
  ret += INS_BRANCH_CONDITIONAL;
  ret += ' ';
  ret += lbl;
  ret += ',';
  ret += ' ';
  ret += pred;
  ret += '\n';
  return ret;
}

std::string
gen_ins_declare_function(std::string const & src)
// returns a string of the form "func src\n"
{
  static std::string const INS_FUNCTION_PREFIX = "func";
  std::string ret;
  ret += INS_FUNCTION_PREFIX;
  ret += ' ';
  ret += src;
  ret += '\n';
  return ret;
}

std::string
gen_ins_end_function()
// returns a string of the form "endfunc\n"
{
  static std::string const INS_FUNCTION_SUFFIX = "endfunc";
  std::string ret;
  ret += INS_FUNCTION_SUFFIX;
  ret += '\n';
  return ret;
}
