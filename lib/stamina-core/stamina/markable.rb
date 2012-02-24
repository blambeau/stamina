module Stamina
  #
  # Allows any object to be markable with user-data.
  #
  # This module is expected to be included by classes that want to implement the
  # Markable design pattern. Moreover, if the instances of the including class
  # respond to <tt>state_changed</tt>, this method is automatically invoked when
  # marks change. This method is used by <tt>automaton</tt> in order to make it
  # possible to track changes and check modified automata for consistency.
  #
  # == Detailed API
  module Markable

    #
    # Returns user-value associated to _key_, nil if no such key in user-data.
    #
    def [](key) @data[key] end

    #
    # Associates _value_ to _key_ in user-data. Overrides previous value if
    # present.
    #
    def []=(key,value)
      oldvalue = @data[key]
      @data[key] = value
      state_changed(:loaded_pair, [key,oldvalue,value]) if self.respond_to? :state_changed
    end

    # Removes a mark
    def remove_mark(key)
      oldvalue = @data[key]
      @data.delete(key)
      state_changed(:loaded_pair, [key,oldvalue,nil]) if self.respond_to? :state_changed
    end

    # Extracts the copy of attributes which can subsequently be modified.
    def data
      @data.nil? ? {} : @data.dup
    end

  end # module Markable
end # module Stamina