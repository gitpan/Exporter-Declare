package Exporter::Declare::Parser::Emulate;
use strict;
use warnings;
use base 'Exporter::Declare::Parser';
use Data::Dumper;

__PACKAGE__->add_accessor( 'test_line' );
__PACKAGE__->register( 'test' );

sub line { shift->test_line( @_ )}

sub skipspace {
    my $self = shift;
    return unless $self->peek_remaining =~ m/^(\s+)/;
    $self->advance(length($1));
}

#XXX !BEWARE! Will not work for nested quoting, even escaped
#             This is a very dumb implementation.
sub _quoted_from_dd {
    my $self = shift;
    my $start = $self->peek_num_chars(1);
    my $end = $self->end_quote( $start );
    my $regex = "^\\$start\([^$end]*)\\$end";
    $self->peek_remaining =~ m/$regex/;
    my $quoted = $1;

    croak( "qfdd regex: |$regex| did not get complete quote." )
        unless $quoted;

    return ( length( $quoted ) + 2, $quoted );
}

sub _peek_is_word {
    my $self = shift;
    my $start = $self->peek_num_chars(1);
    return 0 unless $start =~ m/^[A-Za-z_]$/;
    $self->peek_remaining =~ m/^(\w+)/;
    return length($1);
}

sub _linestr_offset_from_dd {
    my $self = shift;
    return length($self->line);
}

sub type { 'const' }
sub end_hook { 1 };

sub rewrite {
    my $self = shift;
    $self->new_parts( $self->parts );
    1;
}

sub _apply_rewrite {
    my $self = shift;
    $self->SUPER::_apply_rewrite();
    $self->_scope_end("$self") if $self->end_char eq '{';
}

1;

=head1 NAME

Exporter::Declare::Parser::Emulate - Parser that emulates Devel-Declare

=head1 TESTING ONLY

For testing purposes only.

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2010 Chad Granum

Exporter-Declare is free software; Standard perl licence.

Exporter-Declare is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the license for more details.
