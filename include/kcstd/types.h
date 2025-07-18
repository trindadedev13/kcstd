#ifndef __TYPES_H__
#define __TYPES_H__

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;

typedef signed char int8_t;
typedef short int16_t;
typedef int int32_t;
typedef long long int64_t;

typedef unsigned char byte;
typedef unsigned char bool;
#define true 1
#define false 0

#define NULL ((void*)0)
#define null NULL

typedef char* string;

typedef void* buffer;

#if defined(__x86_64__) || defined(_M_X64)
typedef unsigned long size_t;
#elif defined(__i386__) || defined(_M_IX86)
typedef unsigned int size_t;
#elif defined(__aarch64__) || defined(_M_ARM64)
typedef unsigned long size_t;
#elif defined(__arm__) || defined(_M_ARM)
typedef unsigned int size_t;
#elif defined(__riscv) && __riscv_xlen == 64
typedef unsigned long size_t;
#elif defined(__riscv) && __riscv_xlen == 32
typedef unsigned int size_t;
#else
#error "invalid arch."
#endif

#endif