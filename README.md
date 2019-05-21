[![Build Status](https://travis-ci.org/stphnlyd/perl5-Math-LOESS.svg?branch=master)](https://travis-ci.org/stphnlyd/perl5-Math-LOESS)
[![AppVeyor Status](https://ci.appveyor.com/api/projects/status/github/stphnlyd/perl5-Math-LOESS?branch=master&svg=true)](https://ci.appveyor.com/project/stphnlyd/perl5-Math-LOESS)

# NAME

Math::LOESS - Perl wrapper of the Locally-Weighted Regression package originally written by Cleveland, et al.

# VERSION

version 0.0000\_02

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
    Num :$span=0.75)
```

Arguments:

- $x

    A [PDL](https://metacpan.org/pod/PDL) piddle for x data. 

- $y

    A [PDL](https://metacpan.org/pod/PDL) piddle for y data. 

- $weights

    Optional weights.

- $span

    The parameter controls the degree of smoothing. Default is 0.75.

    For `span` < 1, the neighbourhood used for the fit includes proportion
    `span` of the points, and these have tricubic weighting (proportional to
    `(1 - (dist/maxdist)^3)^3)`. For `span` > 1, all points are used, with
    the "maximum distance" assumed to be `span^(1/p)` times the actual
    maximum distance for p explanatory variables.

    When provided as a construction parameter, it is like a shortcut of,

    ```perl
    my $loess = Math::LOESS->new(...); 
    $loess->model->span($span);
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

Returns a [Math:LOESS::Prediction](Math:LOESS::Prediction) object.

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
