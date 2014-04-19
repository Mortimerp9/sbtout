#!/usr/bin/perl

##
# process the output of the sbt command to show only the errors since last compile call
##

open LASTCNT, ">/tmp/sbtlastcnt"; #TODO make this an argument
open SBTIN, "<", $ARGV[1];
$lineCnt = 0;
$from = $ARGV[0];
$found = 0;
$error =0;

while(!$found) {
    while(<SBTIN>) {
        if ($lineCnt++ > $from) {
            s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g;
            if(m/^\[error\] /) {
                $error=1;
            }
#            s/^\[.*\] //;
            print $_;
            if(m/Total time: .*, completed/) {
                $found = 1;
                print LASTCNT $lineCnt."\n";
                break;
            }
        }
    }
    if(!$found) {
# eof reached on FH, but wait a second and maybe there will be more output
        sleep 1;
        seek FH, 0, 1;      # this clears the eof flag on FH
    }
}

print "\n";
close LASTCNT;
close SBTIN;
exit $error;
