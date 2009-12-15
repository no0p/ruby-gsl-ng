/**
 * gsl_extension module: provides some simple C functions in cases where a faster version of some
 * Ruby method is really necessary.
 * This could actually a standard C library (not a Ruby extension), but it's easier this way.
 */

#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>

extern "C" void Init_gslng_extensions(void) { }

/**** Vector *****/

// For Vector::map!
typedef double (*gsl_vector_callback_t)(double);

extern "C" void gsl_vector_map(gsl_vector* v, gsl_vector_callback_t callback) {
	for (size_t i = 0; i < v->size; i++)
		*gsl_vector_ptr(v, i) = (*callback)(*gsl_vector_const_ptr(v, i));
}

// For Vector::map_index!
typedef double (*gsl_vector_index_callback_t)(size_t);

extern "C" void gsl_vector_map_index(gsl_vector* v, gsl_vector_index_callback_t callback) {
	for (size_t i = 0; i < v->size; i++)
		*gsl_vector_ptr(v, i) = (*callback)(i);
}

// A fast "each" for cases where there's no expected return value from the block
typedef void (*gsl_vector_each_callback_t)(double);

extern "C" void gsl_vector_each(gsl_vector* v, gsl_vector_each_callback_t callback) {
	for (size_t i = 0; i < v->size; i++)
		(*callback)(*gsl_vector_const_ptr(v, i));
}

// Hide the view in a new vector (gsl_vector_subvector)
extern "C" gsl_vector* gsl_vector_subvector_with_stride2(gsl_vector* v, size_t offset, size_t stride, size_t n) {
  gsl_vector_view view = gsl_vector_subvector_with_stride(v, offset, stride, n);
  gsl_vector* vector_view = gsl_vector_alloc(view.vector.size);
  *vector_view = view.vector;
  return vector_view;
}

// Hide the view in a new vector (gsl_vector_subvector)
extern "C" gsl_vector* gsl_vector_subvector2(gsl_vector* v, size_t offset, size_t n) {
  gsl_vector_view view = gsl_vector_subvector(v, offset, n);
  gsl_vector* vector_view = gsl_vector_alloc(view.vector.size);
  *vector_view = view.vector;
  return vector_view;
}

/***** Matrix *****/
// For Matrix::map!
typedef double (*gsl_matrix_callback_t)(double);

extern "C" void gsl_matrix_map(gsl_matrix* m, gsl_matrix_callback_t callback) {
  size_t size1 = m->size1;
  size_t size2 = m->size2;

	for (size_t i = 0; i < size1; i++)
    for (size_t j = 0; j < size2; j++)
      *gsl_matrix_ptr(m, i, j) = (*callback)(*gsl_matrix_const_ptr(m, i, j));
}

// For Matrix::map_index!
typedef double (*gsl_matrix_index_callback_t)(size_t, size_t);

extern "C" void gsl_matrix_map_index(gsl_matrix* m, gsl_matrix_index_callback_t callback) {
  size_t size1 = m->size1;
  size_t size2 = m->size2;

	for (size_t i = 0; i < size1; i++)
    for (size_t j = 0; j < size2; j++)
  		*gsl_matrix_ptr(m, i, j) = (*callback)(i, j);
}

// A fast "each" for cases where there's no expected return value from the block
typedef void (*gsl_matrix_each_callback_t)(double);

extern "C" void gsl_matrix_each(gsl_matrix* m, gsl_matrix_each_callback_t callback) {
  size_t size1 = m->size1;
  size_t size2 = m->size2;

	for (size_t i = 0; i < size1; i++)
    for (size_t j = 0; j < size2; j++)
  		(*callback)(*gsl_matrix_const_ptr(m, i, j));
}
