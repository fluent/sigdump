module Sigdump
  VERSION = "0.1.0"

  def self.install_thread_dump_handler(signal, path=nil)
    Kernel.trap(signal) do
      begin
        _open_dump_path(path) do |io|
          io.write "Sigdump at #{Time.now} process #{Process.pid} (#{$0})\n"
          dump_all_thread_backtrace(io)
          dump_object_count(io)
          dump_gc_profiler_result(io)
        end
      rescue
      end
    end
  end

  def self.dump_all_thread_backtrace(io)
    Thread.list.each do |thread|
      dump_backtrace(thread, io)
    end
    nil
  end

  def self.dump_backtrace(thread, io)
    status = thread.status
    if status == nil
      status = "finished"
    elsif status == false
      status = "error"
    end

    backtrace = thread.backtrace

    io.write "  Thread #{thread} status=#{status} priority=#{thread.priority}\n"
    backtrace.each {|bt|
      io.write "      #{bt}\n"
    }

    io.flush
    nil
  end

  def self.dump_object_count(io)
    io.write "  Built-in objects:\n"
    ObjectSpace.count_objects.sort_by {|k,v| -v }.each {|k,v|
      io.write "%10s: %s\n" % [_fn(v), k]
    }

    string_size = 0
    array_size = 0
    hash_size = 0
    cmap = {}
    ObjectSpace.each_object {|o|
      c = o.class
      cmap[c] = (cmap[c] || 0) + 1
      if c == String
        string_size += o.bytesize
      elsif c == Array
        array_size = o.size
      elsif c == Hash
        hash_size = o.size
      end
    }

    io.write "  All objects:\n"
    cmap.sort_by {|k,v| -v }.each {|k,v|
      io.write "%10s: %s\n" % [_fn(v), k]
    }

    io.write "  String #{_fn(string_size)} bytes\n"
    io.write "   Array #{_fn(array_size)} elements\n"
    io.write "    Hash #{_fn(hash_size)} pairs\n"

    io.flush
    nil
  end

  def self.dump_gc_profiler_result(io)
    return unless defined?(GC::Profiler) && GC::Profiler.enabled?
    io.write "  GC profiling result:\n"
    io.write "  Total garbage collection time: %f\n" % GC::Profiler.total_time
    GC::Profiler.result.each_line.map do |line|
      io.write "  #{line}"
    end
    GC::Profiler.clear
    nil
  end

  def self._fn(num)
    s = num.to_s
    if formatted = s.gsub!(/(\d)(?=(?:\d{3})+(?!\d))/, "\\1,")
      formatted
    else
      s
    end
  end
  private_class_method :_fn

  def self._open_dump_path(path, &block)
    case path
    when nil, ""
      path = "/tmp/sigdump-#{Process.pid}.log"
      File.open(path, "a", &block)
    when IO
      yield path
    when "-"
      yield STDIN
    when "+"
      yield STDERR
    else
      File.open(path, "a", &block)
    end
  end
  private_class_method :_open_dump_path
end
