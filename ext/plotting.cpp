#include <gsl/gsl_matrix.h>
#include <unistd.h>

extern "C" bool gsl_matrix_putdata(gsl_matrix* m, int fd) {
  return (write(fd, gsl_matrix_const_ptr(m, 0, 0), m->size1 * m->size2 * sizeof(double)) == 0);
}