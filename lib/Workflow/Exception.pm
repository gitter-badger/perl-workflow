package Workflow::Exception;

# $Id$

use strict;

# Declare some of our exceptions

use Exception::Class (
   'Workflow::Exception::Condition' => {
      isa         => 'Workflow::Exception',
      description => 'Condition failed errors',
   },
   'Workflow::Exception::Configuration' => {
      isa         => 'Workflow::Exception',
      description => 'Configuration errors',
   },
   'Workflow::Exception::Persist' => {
      isa         => 'Workflow::Exception',
      description => 'Persistence errors',
   },
   'Workflow::Exception::Validation' => {
      isa         => 'Workflow::Exception',
      description => 'Validation errors',
   },
);

use Log::Log4perl qw( get_logger );

my %TYPE_CLASSES = (
    condition_error     => 'Workflow::Exception::Condition',
    configuration_error => 'Workflow::Exception::Configuration',
    persist_error       => 'Workflow::Exception::Persist',
    validation_error    => 'Workflow::Exception::Validation',
    workflow_error      => 'Workflow::Exception',
);

$Workflow::Exception::VERSION   = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);
@Workflow::Exception::ISA       = qw( Exporter Exception::Class::Base );
@Workflow::Exception::EXPORT_OK = keys %TYPE_CLASSES;

# Exported shortcuts

sub _mythrow {
    my $type = shift @_;
    my ( $msg, %params ) = _massage( @_ );
    my $log = get_logger();
    $log->error( "$type exception thrown from ", join( ', ', caller ) );
    goto &Exception::Class::Base::throw( $TYPE_CLASSES{ $type },
                                         message => $msg, %params );
}

sub condition_error {
    goto &_mythrow( 'condition_error', @_ );
}

sub configuration_error {
    goto &_mythrow( 'configuration_error', @_ );
}

sub persist_error {
    goto &_mythrow( 'persist_error', @_ );
}

sub validation_error {
    goto &_mythrow( 'validation_error', @_ );
}

sub workflow_error {
    goto &_mythrow( 'workflow_error', @_ );
}

# Override 'throw' so we can massage the message and parameters into
# the right format for E::C

sub throw {
    my $class = shift @_;
    my ( $msg, %params ) = _massage( @_ );
    goto &Exception::Class::Base::throw( $class, message => $msg, %params );
}

sub _massage {
    my @items = @_;
    my %params = ( ref $items[-1] eq 'HASH' )
                   ? %{ pop( @items ) } : ();
    my $msg    = join( '', @items );
    return ( $msg, %params );
}

1;

__END__

=head1 NAME

Workflow::Exception - Base class for workflow exceptions

=head1 SYNOPSIS

 # Standard usage
 use Workflow::Exception qw( workflow_error );

 my $user = $wf->context->param( 'current_user' );
 unless ( $user->check_password( $entered_password ) ) {
   workflow_error "User exists but password check failed";
 }
 
 # Pass a list of strings to form the message
 
 unless ( $user->check_password( $entered_password ) ) {
   workflow_error 'Bad login: ', $object->login_attempted;
 }
 
 # Using other exported shortcuts
 
 use Workflow::Exception qw( configuration_error );
 configuration_error "Field 'foo' must be a set to 'bar'";
 
 use Workflow::Exception qw( validation_error );
 validation_error "Validation for field 'foo' failed: $error";

=head1 DESCRIPTION

First, you should probably look at
L<Exception::Class|Exception::Class> for more usage examples, why we
use exceptions, what they are intended for, etc.

This is the base class for all workflow exceptions. It declares a
handful of exceptions and provides shortcuts to make raising an
exception easier and more readable.

=head1 METHODS

B<throw( @msg, [ \%params ])>

This overrides B<throw()> from L<Exception::Class|Exception::Class> to
add a little syntactic sugar. Instead of:

 $exception_class->throw( message => 'This is my very long error message that I would like to pass',
                          param1  => 'Param1 value',
                          param2  => 'Param2 value' );

You can use:

 $exception_class->throw( 'This is my very long error message ',
                          'that I would like to pass',
                          { param1 => 'Param1 value',
                            param2 => 'Param2 value' } );

And everything will work the same. Combined with the L<SHORTCUTS> this
makes for very readable code:

 workflow_error "Something went horribly, terribly, dreadfully, "
                "frightfully wrong: $@",
                { foo => 'bar' };

=head1 DECLARED EXCEPTION CLASSES

B<Workflow::Exception> - import using C<workflow_error>

B<Workflow::Exception::Condition> - import using C<condition_error>

B<Workflow::Exception::Configuration> - import using C<configuration_error>

B<Workflow::Exception::Persist> - import using C<persist_error>

B<Workflow::Exception::Validation> - import using C<validation_error>

=head1 SEE ALSO

L<Exception::Class|Exception::Class>