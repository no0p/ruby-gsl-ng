/**
 * gsl_extension module: provides some simple C functions in cases where a faster version of some
 * Ruby method is really necessary.
 * This could actually a standard C library (not a Ruby extension), but it's easier this way.
 */

#include <gsl/gsl_vector.h>

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