#!/usr/bin/perl

################################################################################
# table_as_text.pl
# 
# Parses HTML and displays table rows as lines of field-separated text.
# Script is handy for extracting tabular data from a web page.
#
# Usage: table_as_text.pl [--separator=string] [file[s]]
#
# Input can be read from standard input or from one or more files.
# Default field separator is tab character, but can be overriden with
# any string value (including an empty string).
#
# Author: Dean Holbrook
# Date  : 2 December 2012
################################################################################
use strict;
use warnings;
use Getopt::Long;
use HTML::TreeBuilder;

my $separator = "\t";  # field separator defaults to tab

# Parse command line options
GetOptions (
	"separator=s" => \$separator   # string
) or die "Usage: $0 [--separator=string] [file[s]]\n";

# Read content from data source(s)
my $content = do { local $/; <> };

# Build parse tree
my $tree = HTML::TreeBuilder->new_from_content($content);

# Find all tables
my @tables = $tree->look_down('_tag' => 'table');

# Iterate over tables
my $tableNumber;
for my $table (@tables) {
	$tableNumber++;
    print "\nTable $tableNumber\n";

    # Find all rows in table
    my @rows = $table->look_down('_tag' => 'tr');

    # Iterate over rows
    for my $row (@rows) {
    	# Find all header and data cells in the row.
    	# Convert cell contents to plain text.
    	# Display cells on a line, separated by field separator string.
        my @cells = $row->look_down('_tag' => qr/^td$|^th$/);
        next unless @cells;  # skip empty row
        print join($separator, map { $_->as_text } @cells), "\n";
    }
}

