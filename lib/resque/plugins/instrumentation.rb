module Resque
  module Plugins
    module Instrumentation

      def self.instrumentor=(instrumentor)
        @instrumentor = instrumentor
      end

      def self.instrumentor
        @instrumentor ||= NoOpInstrumentor.new
      end

      def self.instrument(name, params = {}, &block)
        instrumentor.instrument(name, params, &block)
      end

      class NoOpInstrumentor
        def instrument(name, params = {}, &block)
          yield if block_given?
        end
      end

      module Job

        # For convenient access to instrumentor in plugin
        def instrument(name, params = {}, &block)
          Resque::Plugins::Instrumentation.instrument(name, params, &block)
        end

        %w(before_enqueue after_enqueue before_dequeue
        after_dequeue before_perform after_perform).each do |hook|
          define_method("#{hook}_with_instrumentation") do |*args|
            instrument("resque.#{hook}", queue: @queue.to_s, job: self.name, args: args)
          end
        end

        def around_perform_with_instrumentation(*args)
          instrument("resque.perform", queue: @queue.to_s, job: self.name, args: args) do
            yield
          end
        end

        def on_failure_with_instrumentation(e, *args)
          instrument("resque.on_failure", queue: @queue.to_s, job: self.name, exception: e, args: args)
        end
      end
    end
  end
end

Resque.before_first_fork = proc { Resque::Plugins::Instrumentation.instrument("resque.before_first_fork") }
Resque.before_fork = proc { Resque::Plugins::Instrumentation.instrument("resque.before_fork") }
Resque.after_fork = proc { Resque::Plugins::Instrumentation.instrument("resque.after_fork") }
Resque.before_pause = proc { Resque::Plugins::Instrumentation.instrument("resque.before_pause") }
Resque.after_pause = proc { Resque::Plugins::Instrumentation.instrument("resque.after_pause") }
