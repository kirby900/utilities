#!/usr/bin/perl

################################################################################
# get_numbered_pics.pl
#
# Download sequentially-numbered JPEG files from a web site
#
# Author: Dean Holbrook
# Date  : 13 October 2012
################################################################################
use strict;
use warnings;
use Getopt::Long;
use WWW::Mechanize;

################################################################################
# Program defaults
################################################################################
my $minIdx = 1;
my $zeroPad = 1;
my $maxRetries = 1;
my $maxFails = 3;
my $referUrl;

(my $PROG = $0) =~ s{.*/}{}; # Get script name, minus path

################################################################################
# Display program usage message and exit
################################################################################
sub Usage {
	print "Usage: $PROG [options] baseurl\n";
	print "Options:\n";
	print "  -m n  minimum index value [default=1]\n";
	print "  -p n  zero pad index value to n digits [default=1]\n";
	print "  -f n  maximum failures [default=3]\n";
	print "  -r url referrer URL [default=null]\n";
	exit 1;
}


################################################################################
# Download URL to local file
################################################################################
sub downloadUrl {
	my($mech,$url,$fileName) = @_ ;
	eval {
		$mech->get($url, ':content_file' => $fileName);
	};
	return $mech->status() ;
}

GetOptions(
	'min=i' => \$minIdx,
	'pad=i' => \$zeroPad,
	'fails=i' => \$maxFails,
    'refer=s' => \$referUrl
) or Usage;

my $baseUrl = shift @ARGV or Usage;

my $mech = WWW::Mechanize->new(autocheck=>1);
$mech->agent_alias('Linux Mozilla');
$mech->add_header( Referer => $referUrl ) if defined $referUrl;


my $failCount = 0;

for (my $idx=$minIdx; $maxFails == 0 or $failCount < $maxFails; $idx++)
{
	my $url;
	if ($zeroPad > 0)
	{
		$url = sprintf "$baseUrl%0*d.jpg", $zeroPad, $idx;
	} else {
		$url = sprintf "$baseUrl%d.jpg", $idx;
	}

	(my $fileName = $url) =~ s{.*/}{};
	while (-e $fileName) { $fileName = "z${fileName}"; }

	print "Trying $url... ";
	my $status = downloadUrl($mech,$url,$fileName);
	if (200 == $status) {
		printf "ok (%d bytes)\n", (-s $fileName);
		$failCount = 0;
	} elsif (404 == $status) {
		# 404 status means resource not found.
		# In this case, do not retry.
		printf "fail (not found)\n" ;
		$failCount++ ;
	} else {
		# This code is for failures other than 404
		printf "fail (%d)\n", $status;
		$failCount++ ;
		for (my $retries=1; $retries <= $maxRetries; $retries++ )
		{
			print "Retrying $url... ";
			my $status = downloadUrl($mech,$url,$fileName);
			if (200 == $status) {
				printf "ok (%d bytes)\n", (-s $fileName);
				$failCount = 0;
				last;
			} else {
				printf "fail (%d)\n", $status;
			}
		}
	}

	sleep 1 ;
}

