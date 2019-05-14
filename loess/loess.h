#include <stdio.h>
#include <stdlib.h>

#define TRUE  1
#define FALSE 0
#define MALLOC(n) safe_malloc(n, __LINE__)

/* Structures */

typedef struct {
    int err_status;
    char *err_msg;
    } loess_errstatus;

typedef struct {
    long    n;
    long    p;
    double  *y;
    double  *x;
    double  *weights;
    } loess_inputs;

typedef struct {
    double span;
    int    degree;
    int    normalize;
    int    parametric[8];
    int    drop_square[8];
    char   *family;
    } loess_model;

typedef struct {
    char   *surface;
    char   *statistics;
    double cell;
    char   *trace_hat;
    int    iterations;
    } loess_control;

typedef struct {
    int   *parameter;
    int   *a;
    double *xi;
    double *vert;
    double *vval;
    } loess_kd_tree;

typedef struct {
    double *fitted_values;
    double *fitted_residuals;
    double enp;
    double residual_scale;
    double one_delta;
    double two_delta;
    double *pseudovalues;
    double trace_hat;
    double *diagonal;
    double *robust;
    double *divisor;
    } loess_outputs;

typedef struct {
    loess_inputs *inputs;
    loess_model *model;
    loess_control *control;
    loess_kd_tree *kd_tree;
    loess_outputs *outputs;
    loess_errstatus status;
} loess;

typedef struct {
    double *fit;
    double *se_fit;
    int se;
    int m;
    double residual_scale;
    double df;
    } prediction;

typedef struct {
    double dfn;
    double dfd;
    double F_value;
    double Pr_F;
    } anova_struct;

typedef struct {
    double *fit;
    double *upper;
    double *lower;
    } confidence_intervals;

//  from loess.c
void loess_model_setup(loess_model *model);
void loess_inputs_setup(double *x, double *y, double *w, long n, long p, loess_inputs *inputs);
void loess_outputs_setup(long n, long p, loess_outputs *outputs);
void loess_control_setup(loess_control *control);
void loess_kd_tree_setup(long n, long p, loess_kd_tree *kd_tree);
void loess_setup(double *x, double *y, double *w, long n, long p, loess *lo);
void loess_fit(loess *lo);
void loess_inputs_free(loess_inputs *inputs);
void loess_outputs_free(loess_outputs *outputs);
void loess_kd_tree_free(loess_kd_tree *kd_tree);
void loess_free_mem(loess *lo);
void loess_summary(loess *lo);
void loess_raw(double *y, double *x, double *weights, double *robust, int *d,
               int*n, double *span, int *degree, int *nonparametric,
               int *drop_square, int *sum_drop_sqr, double *cell, char **surf_stat,
               double *surface, int *parameter, int *a, double *xi, double *vert,
               double *vval, double *diagonal, double *trL, double *one_delta,
               double *two_delta, int *setLf);

//  from loessc.c
void
loess_ise(double *y, double *x, double *x_evaluate, double *weights,
          double *span, int *degree, int *nonparametric, int *drop_square,
          int *sum_drop_sqr, double *cell, int *d, int *n, int *m,
          double *fit, double *L);

void
loess_ifit(int *parameter, int *a, double *xi, double *vert, double *vval,
           int *m, double *x_evaluate, double *fit);

void
loess_dfitse(double *y, double *x, double *x_evaluate, double *weights,
             double *robust, int *family, double *span, int *degree,
             int *nonparametric, int *drop_square, int *sum_drop_sqr,
             int *d, int *n, int *m, double *fit, double *L);
void
loess_dfit(double *y, double *x, double *x_evaluate, double *weights,
           double *span, int *degree, int *nonparametric,
           int *drop_square, int *sum_drop_sqr, int *d, int *n, int *m,
           double *fit);

// from misc.c
void *safe_malloc(size_t n, unsigned long line);
void pointwise(prediction *pre, double coverage, confidence_intervals *ci);
void pw_free_mem(confidence_intervals *ci);
double pf(double q, double df1, double df2);
double ibeta(double x, double a, double b);

// from predict.c
void predict(double *eval, loess *lo, prediction *pre);
void pred_free_mem(prediction *pre);
