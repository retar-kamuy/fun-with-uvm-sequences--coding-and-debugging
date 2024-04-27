#include <stdio.h>

#include "svdpi.h"

void c_code_add(int *z, int a, int b) {
    *z = a + b;
    sv_code(*z);
}
