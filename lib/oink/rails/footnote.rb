module Oink
  module Footnote

    def self.included(base)
      base.class_eval do
        after_filter :add_oink_footnote_to_body
        class_attribute :oink_memory_bloat_threshold, :oink_activerecord_bloat_threshold

        def self.memory_bloat_threshold(val=nil)
          self.oink_memory_bloat_threshold = val
        end

        def self.activerecord_bloat_threshold(val=nil)
          self.oink_activerecord_bloat_threshold = val
        end

        private 

        def add_oink_footnote_to_body
          if of = oink_footnote
            response.body = response.body.sub(/<\/[bB][oO][dD][yY]>/, "#{of}</body>") if response.body.respond_to?(:sub)
          end
        end

        def oink_footnote
          ib = mu = nil
          ar_bloated_class = @is_ar_bloated ? ' class="bloated"' : '' if self.class.oink_activerecord_bloat_threshold
          memory_bloated_class = @is_memory_bloated ? ' class="bloated"' : '' if self.class.oink_memory_bloat_threshold
          ib = "<li#{ar_bloated_class}>AR objects instantiated: <strong>#{@oink_instantiation_breakdown}</strong></li>" if @oink_instantiation_breakdown
          mu = "<li#{memory_bloated_class}>Memory usage: <strong>#{@oink_memory_usage/1024} MB</strong></li>" if @oink_memory_usage
          pid = "<li>PID: <strong>#{$$}</strong></li>"
          if ib || mu
            "<ul id=\"oink-footnotes\">#{ib.to_s + mu.to_s + pid}</ul>"
          end
        end
      end
    end

  end
end
