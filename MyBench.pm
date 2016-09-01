## MySQL benchmarking subs

package MyBench;
use strict;

$main::VERSION = '1.0';

use Exporter;
@MyBench::ISA = 'Exporter';
@MyBench::EXPORT = qw(max min avg tot);

sub fork_and_work($$)
{
    $|=1;

    use strict;
    use IO::Pipe;
    use IO::Select;

    $SIG{CHLD} = 'IGNORE';      ## let the kids die

    my $kids_to_fork = shift;
    my $callback     = shift;
    my $num_kids     = 0;
    my @pipes        = ();
    my @pids         = ();
    my $pid          = undef;

    print "forking: ";

    while ($num_kids < $kids_to_fork)
    {
        my $pipe = new IO::Pipe;

        if ($pid = fork())
        {
            ## parent
            $num_kids++;
            print "+";
            $pipe->reader();
            push @pipes, $pipe;
            push @pids,  $pid;
        }
        elsif (defined $pid)
        {
            ## child
            $pipe->writer();
            ## do work
            my @result = $callback->($num_kids);
            ## return results
            print $pipe "@result\n";
            $pipe->close();
            exit 0;
        }
        else
        {
            print "fork failed: $!\n";
        }
    }

    print "\n";

    ## give them a bit of time to setup
    my $time = int($num_kids / 10) + 1;
    print "sleeping for $time seconds while kids get ready\n";
    sleep $time;

    ## get them started
    kill 1, @pids;

    ## collect the results
    my @results;

    print "waiting: ";

    for my $pipe (@pipes)
    {
        my $data = <$pipe>;
        push @results, $data;
        $pipe->close();
        print "-";
    }

    print "\n";

    return @results;
}

sub compute_results(@)
{
    my $name = shift;
    my $recs = 0;
    my ($Cnt, $Min, $Max, $Avg, $Tot, @Min, @Max);

    while (@_)
    {
        ## 6 elements per record
        my $rec = shift; chomp $rec;
        my ($id, $cnt, $min, $max, $avg, $tot) = split /\s+/, $rec;

        $Cnt += $cnt;
        $Avg += $avg;
        $Tot += $tot;

        push @Min, $min;
        push @Max, $max;

        $recs++;
    }

    $Avg = $Avg / $recs;
    $Min = min(@Min);
    $Max = max(@Max);

    my $Qps = $Cnt / ($Tot / $recs);

    print "$name: $Cnt $Min $Max $Avg $Tot $Qps\n";
    print "  clients : $recs\n";
    print "  queries : $Cnt\n";
    print "  fastest : $Min\n";
    print "  slowest : $Max\n";
    print "  average : $Avg\n";
    print "  serial  : $Tot\n";
    print "  q/sec   : $Qps\n";
}

## some numerical helper functions for arrays

sub max
{
    my $val = $_[0];
    for (@_)
    {
        if ($_ > $val) { $val = $_; }
    }
    return $val;
}

sub min
{
    my $val = $_[0];
    for (@_)
    {
        if ($_ < $val) { $val = $_; }
    }
    return $val;
}

sub avg
{
    my $tot;
    for (@_) { $tot += $_; }
    return $tot / @_;
}

sub tot
{
    my $tot;
    for (@_) { $tot += $_; }
    return $tot;
}

1;
