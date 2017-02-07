#!/usr/bin/env perl
use strict;
use warnings;

open(my $infile1,"<","cis_win10_1511_v1.1.0_index_raw.txt") or die $!;
open(my $outfile1,">","cis_win10_1511_v1.1.0_index_processed.txt") or die $!;

my $pagestring = "P a g e";

while(<$infile1>)
{	
	# remove lines containing "P a g e"
	next if /$pagestring/;

	# remove EOL character if second-last character is not a number
	if (substr($_,length($_)-2,1) !~/^\d/)
	{
		s/\R//g;
	}

	# remove trailing periods and page number
	s/\.+ \d+$//g;

	# for easier imports into CSV
	s/\s\(L1\)\s/!L1!/g;
	s/\s\(L2\)\s/!L2!/g;
	s/\s\(BL\)\s/!BL!/g;
	s/\(Scored\)/!Scored!/g;
	s/\s!S/!S/g;

	print $outfile1 $_;
}