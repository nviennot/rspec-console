# Proxy is really the recorder?
module RSpecConsole
  class Proxy < Struct.new(:run_state,:persisted_config)
    def initialize(run_state, persisted_config=[]); super; end

    [:include, :extend].each do |method|
      define_method(method) do |*args|
        method_missing(method, *args)
      end
    end

    def method_missing(method, *args, &block)
      # persisted_config is the real cache
      self.persisted_config << {
        method: method,
        args: args,
        block: block
      }
      self.run_state.send(method, *args, &block)
    end
  end
end
