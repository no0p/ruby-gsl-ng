#include <gsl/gsl_matrix.h>
#include <unistd.h>

extern "C" int gsl_matrix_putdata(gsl_matrix* m, int fd) {
  int ret = write(fd, m->data, m->size1 * m->size2 * sizeof(double));
  if (ret == -1) return errno;
  else return 0;
}