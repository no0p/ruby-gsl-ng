#ifdef HAVE_PLPLOT

#include <plplot.h>
#include <gsl/gsl_matrix.h>

extern "C" double** plplot_alloc_plplotgrid(gsl_matrix* matrix) {
  double** out_ptr = new double*[matrix->size2];

  // plplot interprets the matrix transposed and flipped
  for (size_t j = 0; j < matrix->size2; j++) {
    out_ptr[j] = new double[matrix->size1];
    for (size_t i = 0; i < matrix->size1; i++) {
      out_ptr[j][i] = gsl_matrix_get(matrix, (matrix->size1 - i - 1), j);
    }
  }

  return out_ptr;
}

extern "C" void plplot_free_plplotgrid(double** grid, size_t size2) {
  for (size_t j = 0; j < size2; j++) {
    delete[] grid[j];
  }
  delete[] grid;
}

extern "C" void plplot_set_grayscale(void) {
  double v[2] = { 0, 1 };
  plscmap1l(1, 2, v, v, v, v, NULL);
}

#endif