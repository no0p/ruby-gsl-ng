#include <gsl/gsl_vector.h>

typedef double (*gsl_vector_callback_t)(double);
typedef double (*gsl_vector_index_callback_t)(size_t);

extern "C" void gsl_vector_map(gsl_vector* v, gsl_vector_callback_t callback) {
	for (size_t i = 0; i < v->size; i++)
		*gsl_vector_ptr(v, i) = (*callback)(*gsl_vector_const_ptr(v, i));
}

extern "C" void gsl_vector_map_index(gsl_vector* v, gsl_vector_index_callback_t callback) {
	for (size_t i = 0; i < v->size; i++)
		*gsl_vector_ptr(v, i) = (*callback)(i);
}

extern "C" void Init_gslng_extensions(void) {

}
