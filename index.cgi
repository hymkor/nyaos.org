#!/usr/bin/perl

print <<HERE
Content-Type: text/html
Location: http://www.nyaos.org/index.cgi?$ENV{QUERY_STRING}
Content-Length: 0

<html><body></body></html>
HERE
