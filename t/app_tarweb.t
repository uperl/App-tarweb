use Test2::V0 -no_srand => 1;
use 5.034;
use experimental qw( signatures );
use App::tarweb;
use Test2::Tools::HTTP;
use Test2::Tools::DOM;
use HTTP::Request::Common;
use Mojo::DOM58;
use URI;

subtest 'basic' => sub {

  my $cli = App::tarweb->new;

  my $called_run = 0;

  my $mock = mock 'Plack::Runner' => (
    override => [
      run => sub ($, $app) {

        $called_run = 1;

        my $url = URI->new('http://localhost');

        my $guard = psgi_app_guard $url => $app;

        $url->path('/');

        http_request
          GET($url),
          http_response {
            http_code 200;
            http_content_type 'text/html';
            http_content dom {
              find 'ul li a' => [
                dom { attr href => 'foo.html'; content 'foo.html' },
                dom { attr href => 'foo.txt';  content 'foo.txt'  },
              ];
            };
          };

        foreach my $href (map { $_->attr('href') } Mojo::DOM58->new(http_tx->res->decoded_content)->find('ul li a')->to_array->@*)
        {
          my $url = URI->new_abs( $href, $url );
          http_request
            GET($url),
            http_response {
              http_code 200;
            }
        }

        $url->path('favicon.ico');

        http_request
          GET($url),
          http_response {
            http_code 200;
          };

      }
    ],
  );

  is $cli->main('corpus/foo.tar'), 0, 'returned 0 on exit';
  ok $called_run, 'called $runner->run';

};

done_testing;


