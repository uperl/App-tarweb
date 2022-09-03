package App::tarweb;

use strict;
use warnings;
use 5.020;
use experimental qw( signatures postderef );
use Browser::Start qw( open_url );
use Plack::Runner;
use Plack::App::Libarchive;
use IO::Socket::INET;
use Path::Tiny qw( path );
use URI;
use Plack::Builder ();

# ABSTRACT: Open an archive file in your web browser!
# VERSION

=head1 SYNOPSIS

 $ tarweb foo.tar.gz

=head1 DESCRIPTION

This class just contains the machinery of the L<tarweb> application.

=head1 SEE ALSO

=over 4

=item L<tarweb>

=back

=cut

sub new ($class)
{
  bless {}, $class;
}

sub main ($self, @ARGV)
{
  my $runner = Plack::Runner->new;

  local $ENV{PLACK_ENV} = 'deployment';

  unshift @ARGV, '--port', $self->_random_port;

  @ARGV = $runner->parse_options(@ARGV)->@*;

  if(@ARGV == 0)
  {
    say STDERR "no archive file given!";
    exit 2;
  }

  my @paths;
  $self->{paths} = \@paths;

  push $runner->{options}->@*, server_ready => sub ($args) {
    my $url = $self->{url} = URI->new("http://127.0.0.1/");
    $url->host($args->{host}) if $args->{host};
    $url->scheme($args->{proto}) if $args->{proto};
    $url->port($args->{port});

    foreach my $path (@paths)
    {
      $url->path($path);
      say $url;
      open_url $url;
    }
  };

  my $app;

  if(@ARGV == 1)
  {
    @paths = ('/');
    $app = Plack::App::Libarchive->new( archive => $ARGV[0] );
  }
  else # @ARGV > 1
  {
    my %dedupe;

    $app = Plack::Builder->new;
    foreach my $fspath (map { path($_) } @ARGV)
    {
      if(-r $fspath)
      {
        my $path = $fspath->basename;

        # make the URL path unique
        {
          my $suffix = '';
          my $i = 0;
          while($dedupe{"$path$suffix"})
          {
            $suffix = "-@{[ $i++ ]}";
          }

          $path .= $suffix;
          $dedupe{$path} = 1;
        }

        push @paths, "/$path";
        $app->mount( "/$path" => Plack::App::Libarchive->new( archive => $fspath )->to_app );
      }
      else
      {
        say STDERR "unable to read $fspath, skipping";
      }
    }
  }

  $runner->run($app->to_app);

  return 0;
}

sub _random_port ($)
{
  IO::Socket::INET->new(
    Listen => 5,
    LocalAddr => '127.0.0.1',
  )->sockport;
}

1;
