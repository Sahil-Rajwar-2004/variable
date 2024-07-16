#include <cuda_device_runtime_api.h>
#include <driver_types.h>
#include <iostream>
#include <cuda_runtime.h>
using namespace std;




extern "C"{
    void cudaCheckError(cudaError_t err,const char* msg){
        if(err != cudaSuccess){
            cerr << msg << ": " << cudaGetErrorString(err) << endl;
            exit(EXIT_FAILURE);
        }
    }

    __global__ void addKernel(const double *x,const double *y,double *z){
        *z = *x + *y;
    }

    __global__ void subKernel(const double *x,const double *y,double *z){
        *z = *x - *y;
    }

    __global__ void mulKernel(const double *x,const double *y,double *z){
        *z = *x * *y;
    }

    __global__ void tdivKernel(const double *x,const double *y,double *z){
        *z = *x / *y;
    }

    __global__ void fdivKernel(const double *x,const double *y,double *z){
        *z = floor(*x / *y);
    }

    __global__ void powKernel(const double *x,const double *y,double *z){
        *z = pow(*x,*y);
    }

    __global__ void modKernel(const double *x,const double *y,double* z){
        *z = fmod(*x,*y);
    }

    __global__ void eqKernel(const double *x,const double *y,int *z){
        *z = (*x == *y) ? 1 : 0;
    }

    __global__ void neKernel(const double *x,const double *y,int *z){
        *z = (*x != *y) ? 1 : 0;
    }

    __global__ void gtKernel(const double *x,const double *y,int *z){
        *z = (*x > *y) ? 1 : 0;
    }

    __global__ void geKernel(const double *x,const double *y,int *z){
        *z = (*x >= *y) ? 1 : 0;
    }

    __global__ void ltKernel(const double *x,const double *y,int *z){
        *z = (*x < *y) ? 1 : 0;
    }

    __global__ void leKernel(const double *x,const double *y,int *z){
        *z = (*x <= *y) ? 1 : 0;
    }

    __global__ void absKernel(const double *x,double *z){
        if(*x >= 0){
            *z = *x;
        }else{
            *z = -*x;
        }
    }

    __global__ void sqrtKernel(const double *x,double *z){
        *z = __dsqrt_rn(*x);
    }

    __global__ void cbrtKernel(const double *x,double *z){
        *z = cbrt(*x);
    }

    __global__ void factKernel(double *x, double *z) {
        unsigned int thread_id = threadIdx.x;
        unsigned int block_dim = blockDim.x;

        __shared__ double cache[1024];

        double result = 1.0;
        for (int i = thread_id + 1;i <= *x;i += block_dim) {
            result *= i;
        }

        cache[thread_id] = result;
        __syncthreads();

        for (unsigned int i = 1;i < block_dim;i *= 2) {
            if (thread_id % (2 * i) == 0) {
                cache[thread_id] *= cache[thread_id + i];
            }
            __syncthreads();
        }

        if (thread_id == 0) {
            *z = cache[0];
        }
    }

    __global__ void negKernel(const double *x,double* z){
        *z = -*x;
    }

    __global__ void posKernel(const double *x,double* z){
        *z = +*x;
    }




    class Var{
        private:
            double *value;

        public:
            Var(const double data){
                cudaCheckError(cudaMalloc(&value,sizeof(double)),"failed to allocate the memory on GPU");                                               // allocate the memory on GPU for double dtype
                cudaCheckError(cudaMemcpy(value,&data,sizeof(double),cudaMemcpyHostToDevice),"failed to copy data from host to dedvice");               // copy memory from CPU to GPU
            }

            ~Var(){
                cudaCheckError(cudaFree(value),"failed to free device memory");                                                                         // delete that memory from the GPU
            }

            double get_value() const {
                double host_value;
                cudaCheckError(cudaMemcpy(&host_value,value,sizeof(double),cudaMemcpyDeviceToHost),"failed to copy data from device to host");           // copy memory from CPU to GPU
                return host_value;
            }

            Var add(const Var &other) const{
                Var result(0.0);
                addKernel<<<1,1>>>(this -> value,other.value,result.value);
                cudaCheckError(cudaGetLastError(),"faield to lauch addKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel excution failed");
                return result;
            }

            Var sub(const Var &other) const {
                Var result(0.0);
                subKernel<<<1,1>>>(this -> value,other.value,result.value);
                cudaCheckError(cudaGetLastError(),"failed to launch subKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                return result;
            }

            Var mul(const Var &other) const {
                Var result(0.0);
                mulKernel<<<1,1>>>(this -> value,other.value,result.value);
                cudaCheckError(cudaGetLastError(),"failed to launch mulKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                return result;
            }

            Var tdiv(const Var &other) const {
                Var result(0.0);
                tdivKernel<<<1,1>>>(this -> value,other.value,result.value);
                cudaCheckError(cudaGetLastError(),"failed to laumch tdivKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                return result;
            }

            Var fdiv(const Var &other) const {
                Var result(0.0);
                fdivKernel<<<1,1>>>(this -> value,other.value,result.value);
                cudaCheckError(cudaGetLastError(),"failed to lauch fdivKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                return result;
            }

            Var pow(const Var &other) const {
                Var result(0.0);
                powKernel<<<1,1>>>(this -> value,other.value,result.value);
                cudaCheckError(cudaGetLastError(),"failed to launch powKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                return result;

            }

            Var mod(const Var &other) const {
                Var result(0.0);
                modKernel<<<1,1>>>(this -> value,other.value,result.value);
                cudaCheckError(cudaGetLastError(),"failed to launch modKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                return result;
            }

            int eq(const Var &other) const {
                int host_result;
                int *device_result;
                cudaCheckError(cudaMalloc(&device_result,sizeof(int)),"failed to allocate the memory on GPU");
                eqKernel<<<1,1>>>(this -> value,other.value,device_result);
                cudaCheckError(cudaGetLastError(),"failed to launch eqKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                cudaCheckError(cudaMemcpy(&host_result,device_result,sizeof(int),cudaMemcpyDeviceToHost),"failed to copy data from device memory to host memory");
                cudaCheckError(cudaFree(device_result),"failed to free the memory from the device memory");
                return host_result;
            }

            int ne(const Var &other) const {
                int host_result;
                int *device_result;
                cudaCheckError(cudaMalloc(&device_result,sizeof(int)),"failed to allocate the memory on GPU");
                neKernel<<<1,1>>>(this -> value,other.value,device_result);
                cudaCheckError(cudaGetLastError(),"failed to launch neKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                cudaCheckError(cudaMemcpy(&host_result,device_result,sizeof(int),cudaMemcpyDeviceToHost),"failed to copy data from device memory to host memory");
                cudaCheckError(cudaFree(device_result),"failed to free the memory from the device memory");
                return host_result;
            }

            int gt(const Var &other) const {
                int host_result;
                int *device_result;
                cudaCheckError(cudaMalloc(&device_result,sizeof(int)),"failed to allocate the memory on GPU");
                gtKernel<<<1,1>>>(this -> value,other.value,device_result);
                cudaCheckError(cudaGetLastError(),"failed to launch gtKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                cudaCheckError(cudaMemcpy(&host_result,device_result,sizeof(int),cudaMemcpyDeviceToHost),"failed to copy data from device memory to host memory");
                cudaCheckError(cudaFree(device_result),"failed to free the memory from the device memory");
                return host_result;
            }

            int ge(const Var &other) const {
                int host_result;
                int *device_result;
                cudaCheckError(cudaMalloc(&device_result,sizeof(int)),"failed to allocate the memory on GPU");
                geKernel<<<1,1>>>(this -> value,other.value,device_result);
                cudaCheckError(cudaGetLastError(),"failed to lauch geKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kenrel execution failed");
                cudaCheckError(cudaMemcpy(&host_result,device_result,sizeof(int),cudaMemcpyDeviceToHost),"falied to copy data from device memory to host memry");
                cudaCheckError(cudaFree(device_result),"failed to free the memory from the device memory");
                return host_result;
            }

            int lt(const Var &other) const {
                int host_result;
                int *device_result;
                cudaCheckError(cudaMalloc(&device_result,sizeof(int)),"failed to allocate the memory on GPU");
                ltKernel<<<1,1>>>(this -> value,other.value,device_result);
                cudaCheckError(cudaGetLastError(),"failed to launch ltKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                cudaCheckError(cudaMemcpy(&host_result,device_result,sizeof(int),cudaMemcpyDeviceToHost),"failed to copy data from device memory to host memory");
                cudaCheckError(cudaFree(device_result),"failed to free the memory from the device memory");
                return host_result;
            }

            int le(const Var &other) const {
                int host_result;
                int *device_result;
                cudaCheckError(cudaMalloc(&device_result,sizeof(int)),"failed to allocate the memory on GPU");
                leKernel<<<1,1>>>(this -> value,other.value,device_result);
                cudaCheckError(cudaGetLastError(),"failed to lauch leKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kenrel execution failed");
                cudaCheckError(cudaMemcpy(&host_result,device_result,sizeof(int),cudaMemcpyDeviceToHost),"falied to copy data from device memory to host memry");
                cudaCheckError(cudaFree(device_result),"failed to free the memory from the device memory");
                return host_result;
            }

            Var abs() const {
                Var result(0.0);
                absKernel<<<1,1>>>(this -> value,result.value);
                cudaCheckError(cudaGetLastError(),"failed to launch absKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                return result;
            }

            Var sqrt() const {
                Var result(0.0);
                sqrtKernel<<<1,1>>>(this -> value,result.value);
                cudaCheckError(cudaGetLastError(),"failed to launch sqrtKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                return result;
            }

            Var cbrt() const {
                Var result(0.0);
                cbrtKernel<<<1,1>>>(this -> value,result.value);
                cudaCheckError(cudaGetLastError(),"failed to launch cbrtKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                return result;
            }

            Var fact() const {
                Var result(0.0);
                factKernel<<<1,1>>>(this -> value,result.value);
                cudaCheckError(cudaGetLastError(),"failed to launch factKerel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                return result;
            }

            Var neg() const {
                Var result(0.0);
                negKernel<<<1,1>>>(this -> value,result.value);
                cudaCheckError(cudaGetLastError(),"failed to launch negKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                return result;
            }

            Var pos() const {
                Var result(0.0);
                posKernel<<<1,1>>>(this -> value,result.value);
                cudaCheckError(cudaGetLastError(),"failed to launch posKernel");
                cudaCheckError(cudaDeviceSynchronize(),"kernel execution failed");
                return result;
            }
    };

    Var *Var_new(double data){ return new Var(data); }
    void Var_delete(Var* var){ delete var; }
    double Var_get_value(Var* var){ return var -> get_value(); }

    Var *Var_add(Var *a,Var *b){ return new Var(a -> add(*b)); }
    Var *Var_sub(Var *a,Var *b){ return new Var(a -> sub(*b)); }
    Var *Var_mul(Var *a,Var *b){ return new Var(a -> mul(*b)); }
    Var *Var_tdiv(Var *a,Var *b){ return new Var(a -> tdiv(*b)); }
    Var *Var_fdiv(Var *a,Var *b){ return new Var(a -> fdiv(*b)); }
    Var *Var_pow(Var *a,Var *b){ return new Var(a -> pow(*b)); }
    Var *Var_mod(Var *a,Var *b){ return new Var(a -> mod(*b)); }

    int Var_eq(Var *a,Var *b){ return a -> eq(*b); }
    int Var_ne(Var *a,Var *b){ return a -> ne(*b); }
    int Var_gt(Var *a,Var *b){ return a -> gt(*b); }
    int Var_ge(Var *a,Var *b){ return a -> ge(*b); }
    int Var_lt(Var *a,Var *b){ return a -> lt(*b); }
    int Var_le(Var *a,Var *b){ return a -> le(*b); }

    Var *Var_abs(Var *a){ return new Var(a -> abs()); }
    Var *Var_sqrt(Var *a){ return new Var(a -> sqrt()); }
    Var *Var_cbrt(Var *a){ return new Var(a -> cbrt()); }
    Var *Var_fact(Var *a){ return new Var(a -> fact()); }
    Var *Var_neg(Var *a){ return new Var(a -> neg()); }
    Var *Var_pos(Var *a){ return new Var(a -> pos()); }
}


