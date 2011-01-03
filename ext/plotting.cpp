#include <gsl/gsl_matrix.h>
#include <unistd.h>
#include <iostream>
using namespace std;

extern "C" int gsl_matrix_putdata(gsl_matrix* m, int fd) {
  size_t bytes = m->size1 * m->size2 * sizeof(double);
  long ret = write(fd, m->data, bytes);
  if (ret == -1 || (unsigned long)ret < bytes) {
    if (errno == EINTR) {
      cout << "retrying write" << endl;
      long written;
      if (ret == -1) written = 0;
      else written = ret;
      
      ret = write(fd, m->data + written, bytes - written);
      if (ret == -1 || (unsigned long)ret < (bytes - written)) return errno;
      else return 0;
    }
  }
  else return 0;
}
