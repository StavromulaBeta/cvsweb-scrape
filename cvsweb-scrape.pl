#!/usr/bin/perl

# This software is provided under the terms of the GNU GPL, version 2.0 
# or later.
#
# Copyright 2006 Arnout Engelen, http://arnout.engelen.eu

use LWP::Simple;
use strict;

# Base url of the cvsweb repository
my $basename = "http://dkc.jhu.edu/cgi-bin/cvsweb.cgi/";
# Desired output directory
my $basedir = "out/";
# Module to check out
my $modulename = "aomr/";

sub fetchdir {
  my ($basename, $dir) = @_;
  my $page = get($basename . $dir) || die "Couldn't get $basename$dir: $!\n";

  mkdir ("$basedir$dir");

  #print "page: $page";
  my $piece = "";
  if ($page =~ /Parent Directory(.*)Show only/s) {
    $piece = $1;
  } elsif ($page =~ /Parent Directory(.*)FreeB/s) {
    $piece = $1;
  } else {
    die "Invalid page: $page\n";
  }
  while ($piece =~ /a href="\.\/([^"]+)">.*[^>]<\/a><\/td>/g) {
    my $nodename = $1;
    print "Getting $nodename ";
    if ($nodename =~ /Attic/) {
    } elsif ($nodename =~ /\/$/) {
      print "(directory)\n";
      fetchdir ($basename, "$dir$nodename");
    } else {
      print "\n";
      # http://dkc.jhu.edu/cgi-bin/cvsweb.cgi/~checkout~/aomr2/gamera/toolkits/omr/__init__.py?rev=1.3&content-type=text/plain
      my $fileurl = $basename . "~checkout~/" . $dir . $nodename;
      my $file = get ($fileurl) ;#|| die "Error getting $fileurl: $!\n";
      open (MYFILE, ">$basedir$dir$nodename");
      print MYFILE $file;
      close (MYFILE);
    }
  }
}

mkdir ($basedir);
fetchdir ($basename, $modulename);
