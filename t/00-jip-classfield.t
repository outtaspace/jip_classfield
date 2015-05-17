#!/usr/bin/env perl

use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use English qw(-no_match_vars);

plan tests => 4;

subtest 'Require some module' => sub {
    plan tests => 4;

    use_ok 'JIP::ClassField', '0.01';
    require_ok 'JIP::ClassField';

    diag(
        sprintf 'Testing JIP::ClassField %s, Perl %s, %s',
            $JIP::ClassField::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );

    can_ok 'JIP::ClassField', qw(attr monkey_patch);
    can_ok __PACKAGE__, qw(has);
};

JIP::ClassField::attr(__PACKAGE__, attr_1 => (get => q{-}, set => q{-}));
JIP::ClassField::attr(__PACKAGE__, attr_2 => (get => q{+}, set => q{-}));
JIP::ClassField::attr(__PACKAGE__, attr_3 => (get => q{-}, set => q{+}));
JIP::ClassField::attr(__PACKAGE__, attr_4 => (get => q{+}, set => q{+}));

JIP::ClassField::attr(__PACKAGE__, attr_5 => (get => q{getter}, set => q{setter}));

subtest 'attr()' => sub {
    plan tests => 5;

    can_ok(__PACKAGE__, qw(_attr_1 _set_attr_1));
    can_ok(__PACKAGE__, qw(attr_2  _set_attr_2));
    can_ok(__PACKAGE__, qw(_attr_3 set_attr_3));
    can_ok(__PACKAGE__, qw(attr_4  set_attr_4));

    can_ok(__PACKAGE__, qw(getter setter));
};

subtest 'getter and setter' => sub {
    plan tests => 2;

    my $obj = bless {}, __PACKAGE__;

    is ref($obj->setter(42)), __PACKAGE__;
    is $obj->getter, 42;
};

package JIP::ClassField::Test;

use JIP::ClassField;
use English qw(-no_match_vars);

has 'name' => (get => q{+}, set => q{+});

sub new {
    my ($class, $name) = @ARG;

    return bless({}, $class)->set_name($name);
}

package main;

subtest 'has()' => sub {
    plan tests => 1;

    my $obj = JIP::ClassField::Test->new(42);

    is $obj->name, 42;
};

