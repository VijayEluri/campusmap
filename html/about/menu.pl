#!/usr/bin/perl
# -----------------------------------------------------------------
# menu.pl -- $desc$
# Copyright 2005 Michael Kelly (jedimike.net)
#
# This program is released under the terms of the GNU General Public
# License as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# Wed Jul 27 23:53:59 PDT 2005
# -----------------------------------------------------------------

use strict;
use warnings;
my %menu = (
	abstract =>		{ name => "Abstract",		url => "index.shtml" },
	editor =>		{ name => "Editor Features",	url => "editor.shtml" },
	interface =>		{ name => "Interface Features",	url => "interface.shtml" },
	plans =>		{ name => "Plans",		url => "plans.shtml" },
	implementation =>	{ name => "Implementation",	url => "/cgi-bin/map.cgi" },
);
my @order = qw( abstract editor interface plans implementation );
my $current = $ENV{'QUERY_STRING'} || $ARGV[0] || '';

print "Content-type: text/html\n\n\t<p>[\n";
my $key;
for (0..$#order){
	$key = $order[$_];
	print "|" if($_ > 0);
	if($key eq $current){
		print qq|\t\t<b>$menu{$key}{'name'}</b>\n|;
	}
	else{
		print qq|\t\t<a href="$menu{$key}{'url'}">$menu{$key}{'name'}</a>\n|;
	}
}
print "\t]</p>\n";