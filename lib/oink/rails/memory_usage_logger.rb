begin
  require 'win32ole'
rescue LoadError
end

module Oink
  module MemoryUsageLogger
    def self.included(klass)
      klass.class_eval do
        after_filter :log_memory_usage
      end
    end
  
    private
      def get_memory_usage
        if defined? WIN32OLE
          wmi = WIN32OLE.connect("winmgmts:root/cimv2")
          mem = 0
          query = "select * from Win32_Process where ProcessID = #{$$}"
          wmi.ExecQuery(query).each do |wproc|
            mem = wproc.WorkingSetSize
          end
          mem.to_i / 1000
        elsif proc_file = File.new("/proc/#{$$}/smaps") rescue nil
          proc_file.map do |line|
            size = line[/Size: *(\d+)/, 1] and size.to_i
          end.compact.sum
        else
          `ps -o vsz= -p #{$$}`.to_i
        end
      end

      def log_memory_usage
        if logger
          @oink_memory_usage = get_memory_usage
          if self.class.oink_memory_bloat_threshold
            @is_memory_bloated = (@oink_memory_usage > (self.class.oink_memory_bloat_threshold)) 
          end
          logger.info("Memory usage: #{@oink_memory_usage}} | PID: #{$$}")
        end
      end
  end
end
