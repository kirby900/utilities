#!/usr/bin/perl

################################################################################
# Find (and optionally delete) duplicate files in a directory tree.
#
# Author: Dean Holbrook
# Date  : 26 March 2011
################################################################################
use strict;
use warnings;
use Getopt::Long;
use File::Find::Duplicates;

my($deleteFlag);
GetOptions(
	'delete' => \$deleteFlag
) or die;

@ARGV > 0 or die "Usage: $0 directory [...]\n";

my @dupes = find_duplicate_files(@ARGV);

foreach my $dupeset (@dupes) {
	printf "\nDuplicate files of size %d: \n", $dupeset->size;
	my $i=0;
	for my $f (sort @{$dupeset->files}) {
		$i++;
		print "\t$f";
		if ($deleteFlag && $i>1) {
			if (unlink $f) {
				print "... deleted\n";
			} else {
				print "... unable to delete\n";
			}
		} else {
			print "\n";
		}
	}
}

