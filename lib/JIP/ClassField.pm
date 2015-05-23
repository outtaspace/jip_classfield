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

=head1 NAME

JIP::ClassField - Declares an attribute for the class

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use JIP::ClassField;

    # Public access to the "foo"
    has 'foo' => (get => '+', set => '+');
    say $self->set_foo(42)->foo; # 42

    # Private access to the "bar"
    has 'bar' => (get => '-', set => '-');
    say $self->_set_bar(42)->_bar; # 42

    # Methods with user defined names
    has 'wtf' => (get => 'wtf_getter', set => 'wtf_setter');
    say $self->wtf_setter(42)->wtf_getter; # 42

=head1 SEE ALSO

Class::Accessor and Mojo::Base.

=head1 AUTHOR

Vladimir Zhavoronkov, C<< <flyweight at yandex.ru> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2015 Vladimir Zhavoronkov.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut


