#!/usr/bin/perl -w

use File::Basename;

$#ARGV == 1 or die "Usage: dir with required files, output file";

my $requiredDir="$ARGV[0]";
my $resultfile="$ARGV[1]";

open(my $rf,'>',"$resultfile") or die $!;

my $count = 0;
opendir(DIR, "$requiredDir" );
@files = grep { /required.*\.txt/ } readdir(DIR);
closedir(DIR);

opendir(DIR, "$requiredDir/required.ND" );
@nd_files = grep { /required.*\.txt/ } readdir(DIR);
closedir(DIR);

@files = sort(@files,@nd_files);
$count = 0;
foreach $x (@files) {
	my $base = basename($x);
	$base =~ s/required-//;
	$base =~ s/\.txt$//;
	$base =~ s/64bit/x86_64/g;
	$base =~ s/^fedora/Fedora/g;
	$base =~ s/^openSUSE/OpenSuSE/g;
	$base =~ s/^redhat/RedHat/g;
    #bug in facter, RH 4.8 is reported as 4
	$base =~ s/^RedHat-4.8/RedHat-4/g;
	$count = $count + 1;

 	open(FILE,"<","$requiredDir/$x") or open(FILE,"<","$requiredDir/required.ND/$x") or die "Unable to open file $x";
	@required = <FILE>;
	close(FILE);
	@required = grep(!/^#/, @required);
	@required = grep(!/^$/, @required);
	my $arch;
	for (@required) {
		$arch = "";
		chomp();
		if (($x =~ /64bit/) && (m/[\.|\s](i\d86)$/) ) {
			$arch = ".$1";
		}

        #more opensuse wierdness. zypper doesn't like x86_64 appended to package names
        if (!( $base =~ /OpenSuSE/ ) ) {
          #unfortunately it seems that with multi architecture packages, it
          #is safer to force the arch
          if (($x =~ /64bit/) && (m/[\.|\s](x86_64)$/) ) {
            $arch = ".$1";
          }
        }
		$_ =~ s/ .*//;
		$_ .= $arch;
	}
	print $rf $base;

    my %hash   = map { $_, 1 } @required;

    #adjust package list so RedHat list can work on CentOS
    delete $hash{ "redhat-release" };
    delete $hash{ "redhat-release-workstation" };

    #adjust package list to remove unnecessary xulrunner
    delete $hash{ "xulrunner" };
    delete $hash{ "xulrunner-devel" };

    #adjust package list to remove unnecessary kernel packages
    delete $hash{ "linux-image-2.6.32-21-generic" };
    delete $hash{ "linux-headers-2.6.32-21" };

    @required = keys %hash;
	foreach (@required) {
		print $rf ",$_";
	}
	print $rf "\n";

}
close($rf);
