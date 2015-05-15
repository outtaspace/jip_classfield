package JIP::ClassField;

use 5.006;
use strict;
use warnings;
use English qw(-no_match_vars);

our $VERSION = '0.01';

# Will be shipping with Perl 5.22
my $NAME = eval {
    require Sub::Util;
    Sub::Util->can('set_subname');
} || sub { $ARG[1] };

sub attr {
    my ($self, $attr, %param) = @ARG;

    my $class = ref $self || $self;

    my %patch;

    if (exists $param{'get'}) {
        my ($method_name, $value) = (q{}, $param{'get'});

        if ($value eq q{+}) {
            $method_name = $attr;
        }
        elsif ($value eq q{-}) {
            $method_name = q{_}. $attr;
        }
        else {
            $method_name = $value;
        }

        $patch{$method_name} = sub {
            my $self = shift;
            return $self->{$attr};
        };
    }

    if (exists $param{'set'}) {
        my ($method_name, $value) = (q{}, $param{'set'});

        if ($value eq q{+}) {
            $method_name = q{set_}. $attr;
        }
        elsif ($value eq q{-}) {
            $method_name = q{_set_}. $attr;
        }
        else {
            $method_name = $value;
        }

        $patch{$method_name} = sub {
            my ($self, $value) = @ARG;
            $self->{$attr} = $value;
            return $self;
        };
    }

    monkey_patch($class, %patch);
}

sub monkey_patch {
    my ($class, %patch) = @ARG;

    no strict 'refs';
    no warnings 'redefine';

    while(my ($method_name, $value) = each %patch) {
        my $full_name = $class .'::'. $method_name;

        *{$full_name} = $NAME->($full_name, $value);
    }
}

sub import {
    my $caller = caller;

    monkey_patch($caller, 'has', sub { attr($caller, @ARG) });
}

1;

__END__

has 'attr_name' => (get => '+', set => '-');

