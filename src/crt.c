#include "kcstd/io.h"

extern int main();

void _start() {
  int ret = main();
  exit(ret);
}