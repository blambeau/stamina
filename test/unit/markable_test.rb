require 'stamina_test'
module Stamina
  # Tests Loaded class
  class MarkableTest < Test::Unit::TestCase

    class MyMarkableObject
      include Markable
      def initialize
        @data = {}
      end
    end

    class MarkableObjectWithStateChanges < MyMarkableObject
      def initialize
        super
        @changes = []
      end

      def state_changed(what, description)
        @changes << what << description
      end

      def changes
        @changes
      end
    end

    # Tests the effect of setting a value
    def test_value_assignments
      @loaded = MyMarkableObject.new

      assert_nil(@loaded[:myownkey])
      assert_nil(@loaded["rr"])

      @loaded[:myownkey] = "myownkey"
      @loaded[12] = :twelve
      assert_equal("myownkey", @loaded[:myownkey])
      assert_equal(:twelve, @loaded[12])
      assert_nil(@loaded["rr"])

      @loaded[:myownkey] = 36
      assert_equal(36, @loaded[:myownkey])
      assert_equal(:twelve, @loaded[12])
      assert_nil(@loaded["rr"])
    end

    # Tests the effect of setting a value
    def test_value_assignments_statechange
      @loaded = MarkableObjectWithStateChanges.new

      assert_nil(@loaded[:myownkey])
      assert_nil(@loaded["rr"])
      assert_equal([],@loaded.changes)

      @loaded[:myownkey] = "myownkey"
      @loaded[12] = :twelve
      assert_equal("myownkey", @loaded[:myownkey])
      assert_equal(:twelve, @loaded[12])
      assert_equal([:loaded_pair,[:myownkey,nil,"myownkey"],:loaded_pair,[12,nil,:twelve]],@loaded.changes)
      assert_nil(@loaded["rr"])

      @loaded[:myownkey] = 36
      assert_equal(36, @loaded[:myownkey])
      assert_equal(:twelve, @loaded[12])
      assert_nil(@loaded["rr"])
      assert_equal([:loaded_pair,[:myownkey,nil,"myownkey"],:loaded_pair,[12,nil,:twelve],:loaded_pair,[:myownkey,"myownkey",36]],@loaded.changes)
    end

    def test_marks
      markable = MyMarkableObject.new
      markable[:hello] = "world"
      markable[:foo] = "bar"
      assert_equal [], markable.marks
      assert_equal ["world"], markable.marks(:hello)
      assert_equal ["bar", "world"], markable.marks(:foo, :hello)
      assert_equal [nil, "world"], markable.marks(:notthatone, :hello)
    end

    def test_raw_data
      markable = MyMarkableObject.new
      assert_equal({}, markable.raw_data)
      markable[:hello] = "world"
      markable[:foo] = "bar"
      assert_equal({:hello => "world", :foo => "bar"}, markable.raw_data)
    end
  end
end