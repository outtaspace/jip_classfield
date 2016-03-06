#!/usr/bin/env perl

use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use English qw(-no_match_vars);

plan tests => 14;

subtest 'Require some module' => sub {
    plan tests => 5;

    use_ok 'JIP::ClassField', '0.04';

    require_ok 'JIP::ClassField';
    is $JIP::ClassField::VERSION, '0.04';

    diag(
        sprintf 'Testing JIP::ClassField %s, Perl %s, %s',
            $JIP::ClassField::VERSION,
            $PERL_VERSION,
            $EXECUTABLE_NAME,
    );

    can_ok 'JIP::ClassField', qw(attr monkey_patch cleanup_namespace);
    can_ok __PACKAGE__, qw(has);
};

eval { JIP::ClassField::attr() } or do {
    like $EVAL_ERROR, qr{^Class \s not \s defined}x;
};
eval { JIP::ClassField::attr(q{}) } or do {
    like $EVAL_ERROR, qr{^Class \s not \s defined}x;
};
eval { JIP::ClassField::attr(__PACKAGE__) } or do {
    like $EVAL_ERROR, qr{^Attribute \s not \s defined}x;
};
eval { JIP::ClassField::attr(__PACKAGE__, q{}) } or do {
    like $EVAL_ERROR, qr{^Attribute \s not \s defined}x;
};
eval { JIP::ClassField::attr(__PACKAGE__, q{bip bip}) } or do {
    like $EVAL_ERROR, qr{^Attribute \s "bip \s bip" \s invalid}x;
};

JIP::ClassField::attr(__PACKAGE__, attr_1 => (get => q{-}, set => q{-}));
JIP::ClassField::attr(__PACKAGE__, attr_2 => (get => q{+}, set => q{-}));
JIP::ClassField::attr(__PACKAGE__, attr_3 => (get => q{-}, set => q{+}));
JIP::ClassField::attr(__PACKAGE__, attr_4 => (get => q{+}, set => q{+}));

JIP::ClassField::attr(__PACKAGE__, attr_5 => (get => q{getter}, set => q{setter}));

JIP::ClassField::attr(__PACKAGE__, attr_6 => (
    get     => q{+},
    set     => q{+},
    default => q{default_value},
));

JIP::ClassField::attr(__PACKAGE__, attr_7 => (
    get     => q{+},
    set     => q{+},
    default => sub { shift->attr_6 },
));

JIP::ClassField::attr(__PACKAGE__, [qw(attr_8 attr_9)] => (
    get => q{+},
    set => q{+},
));

subtest 'attr()' => sub {
    plan tests => 1;

    can_ok __PACKAGE__, qw(
        _attr_1  _set_attr_1
        attr_2   _set_attr_2
        _attr_3  set_attr_3
        attr_4   set_attr_4
        getter   setter
        attr_8   set_attr_8
        attr_9   set_attr_9
    );
};

subtest 'getter and setter' => sub {
    plan tests => 2;

    my $obj = bless {}, __PACKAGE__;

    is ref($obj->setter(42)), __PACKAGE__;
    is $obj->getter,          42;
};

subtest 'multiple attributes' => sub {
    plan tests => 2;

    my $obj = bless {}, __PACKAGE__;

    $obj->set_attr_8(11);
    $obj->set_attr_9(22);

    is $obj->attr_8, 11;
    is $obj->attr_9, 22;
};

subtest 'default value is a constant' => sub {
    plan tests => 3;

    my $obj = bless {}, __PACKAGE__;

    is $obj->set_attr_6(42)->attr_6,    42;
    is $obj->set_attr_6(undef)->attr_6, undef;
    is $obj->set_attr_6->attr_6,        q{default_value};
};

subtest 'default value is a callback' => sub {
    plan tests => 2;

    my $obj = bless {}, __PACKAGE__;

    is $obj->set_attr_7(42)->attr_7,         42;
    is $obj->set_attr_6->set_attr_7->attr_7, q{default_value};
};

subtest 'has()' => sub {
    has(answer => (get => q{+}, set => q{+}));

    my $obj = bless({}, __PACKAGE__)->set_answer(42);

    is $obj->answer, 42;
};

subtest 'cleanup_namespace()' => sub {
    plan tests => 2;

    has(tratata => (get => '+', set => '+'));

    can_ok __PACKAGE__, qw(tratata set_tratata);

    JIP::ClassField::cleanup_namespace(qw(tratata set_tratata));

    ok(not __PACKAGE__->can('tratata') and not __PACKAGE__->can('set_tratata'));
};

package JIP::ClassField::Test;

use JIP::ClassField;
use English qw(-no_match_vars);

# The parentheses optional if predeclared/imported
has answer => (get => q{+}, set => q{+});

sub new {
    my ($class, $answer) = @ARG;

    return bless({}, $class)->set_answer($answer);
}

package main;

subtest 'The parentheses is optional if has() is predeclared/imported' => sub {
    plan tests => 1;

    my $obj = JIP::ClassField::Test->new(42);

    is $obj->answer, 42;
};

