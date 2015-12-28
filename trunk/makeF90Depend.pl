#!/usr/bin/perl -w

foreach $fName (@ARGV) {
	#if($fName=~m/^([^\.]+)\.f90$/){
	if($fName=~m/^(.*\/)([^\/]+)\.f90$/){
		$depFile="$1$2.P";
		$obj="$1$2.o";
		@depends=();
		@targets=();
		push @targets,"$1$2.o";
		#$dir=$1;
		#print "$dir\n";
		#$depFile=~s/\.f90$/\.P/;
		#print $depFile;
		open(INF,$fName) or warn "cant read $fName\n";
		while($str=<INF>){
			if($str=~m/^\s*#*include\s+[\']([^\']+)[\']/i){ #' include
				push @depends, $1;
			}
			if($str=~m/^\s*#*include\s+[\"]([^\"]+)[\"]/i){ #" include
				push @depends, $1;
			}
			#if($str=~m/^\s*#*include\s+[\<]([^\>]+)[\>]/i){ #" include
			#	push @depends, $1;
			#} ### we should leave the < > includes handled by system
			$str=~tr/[A-Z]/[a-z]/; # to lowercase
			if($str=~m/^\s*module\s+([^\s!]+)/){ # module
				push @targets, "./modules/$1.mod";
			}
			if($str=~m/^\s*use\s+([^\s!]+)/){ # use
				push @depends, "./modules/$1.mod"
			}
		}
		close INF;

		push @depends,$fName;

		open(OUTF,">$depFile") or warn "cant write to $depFile\n";
		print OUTF join(" ",@targets)." : ".join(" ",@depends)."\n";
		print OUTF "\t\$(F90) \$(FFLAGS) -c $fName -o $obj \n";
		print OUTF "\n";
		close OUTF;
	}
}

sub usage(){
	print <<__EOL__
makeF90Dependencies vesion 2
usage:
    makdeF90Depend.pl aa.f90 bb.f90 ...

the aa.P bb.P ... will be created and placed in the same directory of the f90 files
"include #include module use" are handled in current version
#include <xxx> is not handled yet. Coz such kind of include should be the lib headers etc.

to simplify the situation, this program made the following assumptions:
    1. the Makefile are placed in the root directory of the whole workdir
    2. all the filenames should be started with ./
    3. modules (include the source files) are placed in ./modules/ and named in lowercase with the surfix of .mod
__EOL__
}

