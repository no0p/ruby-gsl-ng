#include <gsl/gsl_matrix.h>
#include <unistd.h>

extern "C" bool gsl_matrix_putdata(gsl_matrix* m, int fd) {
  return (write(fd, m->data, m->size1 * m->size2 * sizeof(double)) != -1);
}