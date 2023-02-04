[![Build Status](https://travis-ci.org/iynehz/perl5-Math-LOESS.svg?branch=master)](https://travis-ci.org/iynehz/perl5-Math-LOESS)
[![AppVeyor Status](https://ci.appveyor.com/api/projects/status/github/iynehz/perl5-Math-LOESS?branch=master&svg=true)](https://ci.appveyor.com/project/iynehz/perl5-Math-LOESS)

# NAME

Math::LOESS - Perl wrapper of the Locally-Weighted Regression package originally written by Cleveland, et al.

# VERSION

version 0.001000

# SYNOPSIS

```perl
use Math::LOESS;

my $loess = Math::LOESS->new(x => $x, y => $y);

$loess->fit();
my $fitted_values = $loess->outputs->fitted_values;

print $loess->summary();

my $prediction = $loess->predict($new_data, 1);
my $confidence_intervals = $prediction->confidence(0.05);
print $confidence_internals->{fit};
print $confidence_internals->{upper};
print $confidence_internals->{lower};
```

# CONSTRUCTION

```
new((Piddle1D|Piddle2D) :$x, Piddle1D :$y, Piddle1D :$weights=undef,
    Num :$span=0.75, Str :$family='gaussian')
```

Arguments:

- $x

    A `($n, $p)` piddle for x data, where `$p` is number of predictors.
    It's possible to have at most 8 predictors.

- $y

    A `($n, 1)` piddle for y data. 

- $weights

    Optional `($n, 1)` piddle for weights to be given to individual
    observations.
    By default, an unweighted fit is carried out (all the weights are one).

- $span

    The parameter controls the degree of smoothing. Default is 0.75.

    For `span` < 1, the neighbourhood used for the fit includes proportion
    `span` of the points, and these have tricubic weighting (proportional to
    `(1 - (dist/maxdist)^3)^3)`. For `span` > 1, all points are used, with
    the "maximum distance" assumed to be `span^(1/p)` times the actual
    maximum distance for p explanatory variables.

    When provided as a construction parameter, it is like a shortcut for,

    ```
    $loess->model->span($span);
    ```

- $family

    If `"gaussian"` fitting is by least-squares, and if `"symmetric"` a
    re-descending M estimator is used with Tukey's biweight function.

    When provided as a construction parameter, it is like a shortcut for,

    ```
    $loess->model->family($family);
    ```

Bad values in `$x`, `$y`, `$weights` are removed.

# ATTRIBUTES

## model

Get an [Math::LOESS::Model](https://metacpan.org/pod/Math%3A%3ALOESS%3A%3AModel) object.

## outputs

Get an [Math::LOESS::Outputs](https://metacpan.org/pod/Math%3A%3ALOESS%3A%3AOutputs) object.

## x

Get input x data as a piddle.

## y

Get input y data as a piddle.

## weights

Get input weights data as a piddle.

## activated

Returns a true value if the object's `fit()` method has been called.

# METHODS

## fit

```
fit()
```

## predict

```
predict((Piddle1D|Piddle2D) $newdata, Bool $stderr=false)
```

Returns a [Math::LOESS::Prediction](https://metacpan.org/pod/Math%3A%3ALOESS%3A%3APrediction) object.

Bad values in `$newdata` are removed.

## summary

```
summary()
```

Returns a summary string. For example, 

```
print $loess->summary();
```

# SEE ALSO

[https://en.wikipedia.org/wiki/Local\_regression](https://en.wikipedia.org/wiki/Local_regression)

[PDL](https://metacpan.org/pod/PDL)

# AUTHOR

Stephan Loyd <sloyd@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2019-2023 by Stephan Loyd.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
