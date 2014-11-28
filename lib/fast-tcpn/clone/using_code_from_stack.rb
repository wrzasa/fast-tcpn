module FastTCPN
  DontCloneClasses = [ Fixnum, Symbol, TrueClass, FalseClass, NilClass ]
  module Clone
  # :nodoc:
    def clone(token)
      if DontCloneClasses.include? token.class
        token
      else
        token.clone.deep_clone
      end
    end
  end
end

# http://stackoverflow.com/questions/8206523/how-to-create-a-deep-copy-of-an-object-in-ruby
class Object
  def deep_clone
    return @deep_cloning_obj if @deep_cloning
    @deep_cloning_obj = clone
    @deep_cloning_obj.instance_variables.each do |var|
      val = @deep_cloning_obj.instance_variable_get(var)
      begin
        @deep_cloning = true
        val = val.deep_clone
      rescue TypeError
        next
      ensure
        @deep_cloning = false
      end
      @deep_cloning_obj.instance_variable_set(var, val)
    end
    deep_cloning_obj = @deep_cloning_obj
    @deep_cloning_obj = nil
    deep_cloning_obj
  end
end

FastTCPN::DontCloneClasses.each do |klazz|
  klazz.class_eval do
    def deep_clone
      self
    end
  end
end


