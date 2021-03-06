require 'minitest/autorun'
require 'jschema'

require_relative 'assertions'

class TestEnum < Minitest::Test
  include Assertions

  def test_that_argument_is_non_empty_array_of_unique_values
    assert_raises_unless_non_empty_array 'enum'
  end

  def test_passing_validation
    assert validator(['test']).valid?('test')
  end

  def test_passing_validtion_with_null
    assert validator([nil]).valid?(nil)
  end

  def test_failing_validation
    refute validator(['test']).valid?(0)
  end

  private

  def validator_class
    JSchema::Validator::Enum
  end
end
