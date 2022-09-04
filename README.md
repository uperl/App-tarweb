# tarweb ![static](https://github.com/uperl/App-tarweb/workflows/static/badge.svg) ![linux](https://github.com/uperl/App-tarweb/workflows/linux/badge.svg)

Open an archive file in your web browser!

# SYNOPSIS

Starts a HTTP server locally, and opens it in your web browser

```
$ tarweb [ options ] foo.tar.gz
```

# DESCRIPTION

This is a hybrid CLI/Web app that opens an archive in your browser
so that you can browse the content.  Internally it uses
[libarchive](https://libarchive.org), so any format it supports is
supported by this application.

This command accepts that same options as [plackup](https://metacpan.org/pod/plackup).  Unlike
[plackup](https://metacpan.org/pod/plackup) if you do not specify a port, a random port will
be used instead of using port `5000` so that multiple instances
of this app can run at the same time.

# SEE ALSO

- [Plack::App::Libarchive](https://metacpan.org/pod/Plack::App::Libarchive)
- [Archive::Libarchive](https://metacpan.org/pod/Archive::Libarchive)
- [https://libarchive.org](https://libarchive.org)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2022 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
