package Time::Human;

require 5.005_62;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Time::Human ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	humantime
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
    humanize
	
);
our $VERSION = '1.02';

our %templates = (

    English => {
        numbers  => [ qw(one two three four five six seven eight nine ten eleven twelve) ],
        vagueness=> [ "exactly", "just after", "a little after", "coming up to", "almost"],
        daytime  => [ "in the morning", "in the afternoon", "in the evening", "at night" ],
        minutes  => ["five past", "ten past", "quarter past", "twenty past",
                    "twenty-five past", "half past", "twenty-five to",
                    "twenty to", "quarter to", "ten to", "five to"],
        oclock   => "o'clock",
        midnight => "midnight",
        midday   => "midday",
        format   => "%v %m %h %d",
    }
);

our $Language = "English";
our $Evening = 18;
our $Night = 22;

# Preloaded methods go here.

sub humanize_base {
    my ($hour, $minute) = @_[2,1];
    my $vague = $minute % 5;
    my $close_minute = $minute-$vague;
    my $t = $templates{$Language};
    my $say_hour;
    my $daytime ="";
    if ($vague > 2) {$close_minute += 5} 
    if ($close_minute >30) { $hour++; $hour %=24; }
    $close_minute /= 5;
    $close_minute %= 12;
    if ($hour ==0) {
        $say_hour = $t->{midnight};
    } elsif ($hour == 12) {
        $say_hour = $t->{midday};
    } else {
        $say_hour = $t->{numbers}[$hour%12-1];
        $daytime = $hour <= 12 ? ($t->{daytime}[0]) :
                    $hour >= $Night ? $t->{daytime}[3] :
                    ($hour >= $Evening ? $t->{daytime}[2] :
                    $t->{daytime}[1]); # Afternoon
    }
    if ($close_minute==0) {
        $say_hour .= " ". $t->{oclock} unless $hour ==0 or $hour == 12;
    }
    my $say_min = $close_minute ==0? "" : $t->{minutes}[$close_minute-1];
    my $rv = $t->{format};
    $rv =~ s/%v/$t->{vagueness}[$vague]/eg;
    $rv =~ s/%m/$say_min/g;
    $rv =~ s/%h/$say_hour/g;
    $rv =~ s/%d/$daytime/g;
    return $rv;
}

sub humanize {
    my @foo = humanize_base(@_);
    return (shift(@foo)." @foo");
}

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Time::Human - Convert localtime() format to "speaking clock" time

=head1 SYNOPSIS

  use Time::Human;
  print "The time is now ", humanize(localtime());

=head1 DESCRIPTION

This module provides a "vague" rendering of the time into natural
language; it's originally intended for text-to-speech applications
and other speech-based interfaces. 

It's fully internationalised: if you look at the code, you'll see a
global variable called C<%Time::Human::templates>, which you can fill in
for other languages. If you do multinationalise it, please send me
templates for other languages to be added to future releases. You can
set the default language via the global variable
C<$Time::Human::Language>

C<$Time::Human::Evening> and C<$Time::Human::Night> decide the hours
at which afternoon turns to evening and evening turns to night in
your culture. For instance, Greeks may want evening to start at 11pm; 
for hackers, evening may start at 3am.

=head2 EXPORT

C<humanize> is exported.

=head2 LICENSE

This module may be distributed under the same terms as Perl itself, that
is, GPL or Artistic license at your choice. This software is a gift, not
a burden, and as such is totally unsupported. I'll take patches gladly
but reserve the right to ignore support email about it.

=head1 AUTHOR

Simon Cozens, C<simon@cpan.org>

=head1 SEE ALSO

perl(1).

=cut
