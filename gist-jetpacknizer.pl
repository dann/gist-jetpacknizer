#!/usr/bin/env perl
use strict;
use warnings;
use Text::MicroMason;
use HTTP::Engine;
use Getopt::Long;
use Pod::Usage;

my %argv = (
    host => 'localhost',
    port => '4567',
);

main();
exit;

our $RENDERER;

sub main {
    _setup_options();
    _setup_renderer();
    _setup_engine();
}

sub _setup_options {
    GetOptions( \%argv, "host=s", "port=i" ) or pod2usage(2);
}

sub _setup_renderer {
    my $mason = Text::MicroMason->new( -Filters );
    my $template = join '', <DATA>;
    $RENDERER = $mason->compile( text => $template );
}

sub _setup_engine {
    my $engine = HTTP::Engine->new(
        interface => {
            module => 'ServerSimple',
            args   => {
                host => $argv{host},
                port => $argv{port},
            },
            request_handler => \&handle_request,
        },
    );
    $engine->run;
}

sub handle_request {
    my $req = shift;
    if ( $req->uri->path =~ m{^/(\w+)} ) {
        my $index_page = $RENDERER->( gist_id => $1 );
        return render($index_page);
    }
    else {
        return not_found();
    }
}

sub render {
    my $body = shift;
    HTTP::Engine::Response->new( body => $body );
}

sub not_found {
    return HTTP::Engine::Response->new(
        status => 404,
        body   => "oops \n"
    );
}

__DATA__
<%args>
$gist_id
</%args>
<?xml version="1.0" encoding="UTF-8" ?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>gist jetpacknizer</title>
<link rel="jetpack" href="http://gist.github.com/<% $gist_id |h %>.txt">
</head>
<body>
</body>


