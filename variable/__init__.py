import os
import ctypes
import platform
from typing import Union
from ctypes import POINTER,Structure,c_int,c_double

if platform.system() == "Windows": raise SystemError("this library isn't compatible for Windows users")
elif platform.system() == "Linux": ext = "so"
else: raise SystemError(f"this library isn't compatible for {platform.system()}!")

lib_path = os.path.join(os.path.dirname(__file__),f"libvar.{ext}")
if not os.path.exists(lib_path): raise FileNotFoundError(f"Could not find the library file: {lib_path}")

try: lib = ctypes.CDLL(lib_path)
except OSError as e: raise OSError(f"error loading library: {e}")


class Var(Structure): pass

lib.Var_new.argtypes = [c_double]
lib.Var_new.restype = POINTER(Var)

lib.Var_delete.argtypes = [POINTER(Var)]
lib.Var_delete.restype = None

lib.Var_get_value.argtypes = [POINTER(Var)]
lib.Var_get_value.restype = c_double

lib.Var_add.argtypes = [POINTER(Var),POINTER(Var)]
lib.Var_add.restype = POINTER(Var)

lib.Var_sub.argtypes = [POINTER(Var),POINTER(Var)]
lib.Var_sub.restype = POINTER(Var)

lib.Var_mul.argtypes = [POINTER(Var),POINTER(Var)]
lib.Var_mul.restype = POINTER(Var)

lib.Var_tdiv.argtypes = [POINTER(Var),POINTER(Var)]
lib.Var_tdiv.restype = POINTER(Var)

lib.Var_fdiv.argtypes = [POINTER(Var),POINTER(Var)]
lib.Var_fdiv.restype = POINTER(Var)

lib.Var_pow.argtypes = [POINTER(Var),POINTER(Var)]
lib.Var_pow.restype = POINTER(Var)

lib.Var_mod.argtypes = [POINTER(Var),POINTER(Var)]
lib.Var_mod.restype = POINTER(Var)

lib.Var_eq.argtypes = [POINTER(Var),POINTER(Var)]
lib.Var_eq.restype = c_int

lib.Var_ne.argtypes = [POINTER(Var),POINTER(Var)]
lib.Var_ne.restype = c_int

lib.Var_gt.argtypes = [POINTER(Var),POINTER(Var)]
lib.Var_gt.restype = c_int

lib.Var_ge.argtypes = [POINTER(Var),POINTER(Var)]
lib.Var_ge.restype = c_int

lib.Var_lt.argtypes = [POINTER(Var),POINTER(Var)]
lib.Var_lt.restype = c_int

lib.Var_le.argtypes = [POINTER(Var),POINTER(Var)]
lib.Var_le.restype = c_int

lib.Var_abs.argtypes = [POINTER(Var)]
lib.Var_abs.restype = POINTER(Var)

lib.Var_sqrt.argtypes = [POINTER(Var)]
lib.Var_sqrt.restype = POINTER(Var)

lib.Var_cbrt.argtypes = [POINTER(Var)]
lib.Var_cbrt.restype = POINTER(Var)

lib.Var_fact.argtypes = [POINTER(Var)]
lib.Var_fact.restype = POINTER(Var)

lib.Var_neg.argtypes = [POINTER(Var)]
lib.Var_neg.restype = POINTER(Var)

def variable(x: Union[int,float,bool]): return Variable(x)


class Variable:
    def __init__(self,value: Union[int,float,bool]): self.__obj = lib.Var_new(value)

    def __del__(self):
        if self.__obj and isinstance(self.__obj,POINTER(Var)):
            lib.Var_delete(self.__obj)

    def __repr__(self): return f"{lib.Var_get_value(self.__obj)}"

    def value(self): return lib.Var_get_value(self.__obj)

    def __add__(self,other):
        result = Variable(0.0)
        result.__obj = lib.Var_add(self.__obj,other.__obj)
        return result

    def __sub__(self,other):
        result = Variable(0.0)
        result.__obj = lib.Var_sub(self.__obj,other.__obj)
        return result

    def __mul__(self,other):
        result = Variable(0.0)
        result.__obj = lib.Var_mul(self.__obj,other.__obj)
        return result

    def __truediv__(self,other):
        result = Variable(0.0)
        result.__obj = lib.Var_tdiv(self.__obj,other.__obj)
        return result
    
    def __floordiv__(self,other):
        result = Variable(0.0)
        result.__obj = lib.Var_fdiv(self.__obj,other.__obj)
        return result

    def __pow__(self,other):
        result = Variable(0.0)
        result.__obj = lib.Var_pow(self.__obj,other.__obj)
        return result
    
    def __mod__(self,other):
        result = Variable(0.0)
        result.__obj = lib.Var_mod(self.__obj,other.__obj)
        return result

    def __neg__(self):
        result = Variable(0.0)
        result.__obj = lib.Var_neg(self.__obj)
        return result

    def __pos__(self): return self 

    def __eq__(self,other): return bool(lib.Var_eq(self.__obj,other.__obj))

    def __ne__(self,other): return bool(lib.Var_ne(self.__obj,other.__obj))

    def __gt__(self,other): return bool(lib.Var_gt(self.__obj,other.__obj))

    def __ge__(self,other): return bool(lib.Var_ge(self.__obj,other.__obj))

    def __lt__(self,other): return bool(lib.Var_lt(self.__obj,other.__obj))

    def __le__(self,other): return bool(lib.Var_le(self.__obj,other.__obj))

    def __abs__(self):
        result = Variable(0.0)
        result.__obj = lib.Var_abs(self.__obj)
        return result

    def sqrt(self):
        result = Variable(0.0)
        result.__obj = lib.Var_sqrt(self.__obj)
        return result

    def cbrt(self):
        result = Variable(0.0)
        result.__obj = lib.Var_cbrt(self.__obj)
        return result

    def fact(self):
        result = Variable(0)
        result.__obj = lib.Var_fact(self.__obj)
        return result

