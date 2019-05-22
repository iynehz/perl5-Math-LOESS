[![Build Status](https://travis-ci.org/stphnlyd/perl5-Math-LOESS.svg?branch=master)](https://travis-ci.org/stphnlyd/perl5-Math-LOESS)
[![AppVeyor Status](https://ci.appveyor.com/api/projects/status/github/stphnlyd/perl5-Math-LOESS?branch=master&svg=true)](https://ci.appveyor.com/project/stphnlyd/perl5-Math-LOESS)

# NAME

Math::LOESS - Perl wrapper of the Locally-Weighted Regression package originally written by Cleveland, et al.

# VERSION

version 0.0000\_03

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
new(Piddle1D :$x, Piddle1D :$y, Piddle1D :$weights=undef,
    Num :$span=0.75, Str :$family='gaussian')
```

Arguments:

- $x

    A [PDL](https://metacpan.org/pod/PDL) piddle for x data.

    In case of multiple predictors, `$x` is a glued piddle containing all
    predictors' data. It's possible to have at most 8 predictors.

- $y

    A [PDL](https://metacpan.org/pod/PDL) piddle for y data. 

- $weights

    Optional weights.

- $span

    _POD INCLUDE ERROR: Can't load template 'span' from 'Math::LOESS::Model'._

    When provided as a construction parameter, it is like a shortcut for,

    ```
    $loess->model->span($span);
    ```

- $family

    _POD INCLUDE ERROR: Can't load template 'family' from 'Math::LOESS::Model'._

    When provided as a construction parameter, it is like a shortcut for,

    ```
    $loess->model->family($family);
    ```

# NAME

Math::LOESS - Perl wrapper of the Locally-Weighted Regression package originally written by Cleveland, et al.

# ATTRIBUTES

## model

Get an [Math::LOESS::Model](https://metacpan.org/pod/Math::LOESS::Model) object.

## outputs

Get an [Math::LOESS::Outputs](https://metacpan.org/pod/Math::LOESS::Outputs) object.

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
predict(Piddle1D $newdata, Bool $stderr=false)
```

Returns a [Math::LOESS::Prediction](https://metacpan.org/pod/Math::LOESS::Prediction) object.

## summary

```
summary()
```

Returns a summary string.

# SEE ALSO

[https://en.wikipedia.org/wiki/Local\_regression](https://en.wikipedia.org/wiki/Local_regression)

[PDL](https://metacpan.org/pod/PDL)

# AUTHOR

Stephan Loyd <sloyd@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Stephan Loyd.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
