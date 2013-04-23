# sigdump

Server applications (like Rails app) cause performance problems, deadlock or memory swapping from time to time. But it's painful to reproduce such kind of problems. If we can get information from a running process without restarting it, and it's really helpful.

`sigdump` gem installs a signal handler which dumps backtrace of running threads and number of allocated objects per class.

# Install

Just install one gem `sigdump` and require `sigdump/setup`:

    gem 'sigdump', :require => 'sigdump/setup'

# Usage

Send `SIGCONT` signal to dump backtrace and heap status to `/tmp/sigdump-<pid>.log`:

    $ kill -CONT <pid>

Set `SIGDUMP_SIGNAL` environment variable to change the signal (default: SIGCONT).

Set `SIGDUMP_PATH` environment variable to change the output path (default: /tmp/sigdump-\<pid\>.log). You can set "-" here to dump to STDOUT, "+" to dump to STDERR.

