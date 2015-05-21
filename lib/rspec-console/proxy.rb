# Proxy is really the recorder?
class RSpecConsole::Proxy < Struct.new(:target,:output) do
    def initialize(target, output=[]); super; end
  end

  [:include, :extend].each do |method|
    define_method(method) do |*args|
      method_missing(method, *args)
    end
  end

  def method_missing(method, *args, &block)
    # output is the real cache
    self.output << {
      method: method,
      args: args,
      block: block
    }
    self.target.send(method, *args, &block)
  end
end
