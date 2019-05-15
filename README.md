[![Build Status](https://travis-ci.org/stphnlyd/perl5-Math-LOESS.svg?branch=master)](https://travis-ci.org/stphnlyd/perl5-Math-LOESS)
[![AppVeyor Status](https://ci.appveyor.com/api/projects/status/github/stphnlyd/perl5-Math-LOESS?branch=master&svg=true)](https://ci.appveyor.com/project/stphnlyd/perl5-Math-LOESS)

# NAME

Math::LOESS - Perl wrapper of the Locally-Weighted Regression package originally written by Cleveland, et al.

# SYNOPSIS

```perl
use Math::LOESS;

my $loess = Math::LOESS->new(x => $x_piddle, y => $y_piddle);

$loess->fit();
my $fitted_values = $loess->outputs->fitted_values;
```

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

# METHODS

## fit

```
fit()
```

# SEE ALSO

[https://en.wikipedia.org/wiki/Local\_regression](https://en.wikipedia.org/wiki/Local_regression)

[PDL](https://metacpan.org/pod/PDL)
