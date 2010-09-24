#include <gsl/gsl_matrix.h>
#include <unistd.h>

extern "C" int gsl_matrix_putdata(gsl_matrix* m, int fd) {
  size_t bytes = m->size1 * m->size2 * sizeof(double);
  long ret = write(fd, m->data, bytes);
  if (ret == -1 || (unsigned long)ret < bytes) return errno;
  else return 0;
}
