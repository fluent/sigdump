# sigdump

In short: *SIGQUIT of Java VM for Ruby.*

Server applications (like Rails app) cause performance problems, deadlock or memory swapping from time to time. But it's painful to reproduce such kind of problems. If we can get information from a running process without restarting it, it's really helpful.

`sigdump` gem makes it possible. It installs a signal handler which dumps backtrace of running threads, number of allocated objects per class, and GC statistics.

If GC profiler is enabled (`GC::Profiler.enable` is called), it also dumps GC profiler reports. If the runtime is JRuby, it dumpds Java stacktrace in addition to Ruby stacktrace.

## Install

Just install one gem `sigdump` and require `sigdump/setup`:

```ruby
gem 'sigdump', :require => 'sigdump/setup'
```

### Resque

Because Resque traps `SIGCONT` and it conflicts with sigdump, you need to change the signal such as `SIGTSTP`.
To change the signal, set name of a signal to `SIGDUMP_SIGNAL` environment variable.

```ruby
# environment.rb:
# setup sigdump: https://github.com/frsyuki/sigdump
ENV['SIGDUMP_SIGNAL'] = 'TSTP'
require 'sigdump/setup'
```

## Usage

Send `SIGCONT` signal to dump backtrace and heap status to `/tmp/sigdump-<pid>.log` file:

```shell
$ kill -CONT <pid>
$ cat /tmp/sigdump-<pid>.log
```

Set `SIGDUMP_SIGNAL` environment variable to change the signal (default: SIGCONT).

Set `SIGDUMP_PATH` environment variable to change the output path (default: /tmp/sigdump-\<pid\>.log). You can set "-" here to dump to STDOUT, or "+" to STDERR.

## Sample outout

    $ cat /tmp/sigdump-9218.log
    Sigdump at 2013-04-24 16:57:12 +0000 process 9218 (unicorn worker[3] -E staging -c /etc/unicorn/staging.rb -E staging)
      Thread #<Thread:0x00000001424518> status=run priority=0
          /srv/staging/current/vendor/bundle/ruby/1.9.1/gems/sigdump-0.1.0/lib/sigdump.rb:32:in `dump_backtrace'
          /srv/staging/current/vendor/bundle/ruby/1.9.1/gems/sigdump-0.1.0/lib/sigdump.rb:19:in `block in dump_all_thread_backtrace'
          /srv/staging/current/vendor/bundle/ruby/1.9.1/gems/sigdump-0.1.0/lib/sigdump.rb:18:in `each'
          /srv/staging/current/vendor/bundle/ruby/1.9.1/gems/sigdump-0.1.0/lib/sigdump.rb:18:in `dump_all_thread_backtrace'
          /srv/staging/current/vendor/bundle/ruby/1.9.1/gems/sigdump-0.1.0/lib/sigdump.rb:9:in `block (2 levels) in install_thread_dump_handler'
          /srv/staging/current/vendor/bundle/ruby/1.9.1/gems/sigdump-0.1.0/lib/sigdump.rb:91:in `open'
          /srv/staging/current/vendor/bundle/ruby/1.9.1/gems/sigdump-0.1.0/lib/sigdump.rb:91:in `_open_dump_path'
          /srv/staging/current/vendor/bundle/ruby/1.9.1/gems/sigdump-0.1.0/lib/sigdump.rb:7:in `block in install_thread_dump_handler'
          /srv/staging/current/vendor/bundle/ruby/1.9.1/gems/unicorn-4.3.1/lib/unicorn/http_server.rb:626:in `call'
          /srv/staging/current/vendor/bundle/ruby/1.9.1/gems/unicorn-4.3.1/lib/unicorn/http_server.rb:626:in `select'
          /srv/staging/current/vendor/bundle/ruby/1.9.1/gems/unicorn-4.3.1/lib/unicorn/http_server.rb:626:in `worker_loop'
          /srv/staging/current/vendor/bundle/ruby/1.9.1/gems/unicorn-4.3.1/lib/unicorn/http_server.rb:487:in `spawn_missing_workers'
          /srv/staging/current/vendor/bundle/ruby/1.9.1/gems/unicorn-4.3.1/lib/unicorn/http_server.rb:137:in `start'
          /srv/staging/current/vendor/bundle/ruby/1.9.1/gems/unicorn-4.3.1/bin/unicorn:121:in `<top (required)>'
          /srv/staging/current/vendor/bundle/ruby/1.9.1/bin/unicorn:23:in `load'
          /srv/staging/current/vendor/bundle/ruby/1.9.1/bin/unicorn:23:in `<main>'
      GC stat:
          count: 34
          heap_allocated_pages: 1366
          heap_sorted_length: 1368
          heap_allocatable_pages: 0
          heap_available_slots: 556777
          heap_live_slots: 551708
          heap_free_slots: 5069
          heap_final_slots: 0
          heap_marked_slots: 363350
          heap_swept_slots: 58807
          heap_eden_pages: 1366
          heap_tomb_pages: 0
          total_allocated_pages: 1367
          total_freed_pages: 1
          total_allocated_objects: 2438499
          total_freed_objects: 1886791
          malloc_increase_bytes: 650416
          malloc_increase_bytes_limit: 16777216
          minor_gc_count: 25
          major_gc_count: 9
          remembered_wb_unprotected_objects: 5122
          remembered_wb_unprotected_objects_limit: 5222
          old_objects: 348964
      Built-in objects:
       367,492: TOTAL
       208,193: T_STRING
        61,817: T_ARRAY
        37,343: T_DATA
        28,293: T_NODE
        10,678: T_OBJECT
         6,385: T_HASH
         5,957: T_CLASS
         2,300: T_ICLASS
         2,184: T_REGEXP
         1,547: T_MODULE
           900: T_FLOAT
           677: T_STRUCT
           497: T_BIGNUM
           432: T_MATCH
           251: T_RATIONAL
            29: T_FILE
             8: FREE
             1: T_COMPLEX
      All objects:
       207,335: String
        32,987: Array
        28,665: RubyVM::InstructionSequence
         5,863: Hash
         3,759: RubyVM::Env
         3,680: Proc
         2,338: Class
         2,184: Regexp
         1,632: MIME::Type
         1,547: Module
         1,040: Gem::Version
           982: Gem::Requirement
           945: Float
           920: Journey::Nodes::Cat
           804: Time
           660: Gem::Dependency
           497: Bignum
      ...
      String 7,556,137 bytes
       Array 821 elements
        Hash 90 pairs

