require "minitest"
require 'minitest/autorun'
require_relative "scv"

class SCVsTest < Minitest::Test
  def test_can_do_9_3_and_1_damage
    assert_equal 1, SCVs.new([9, 3, 1]).min_attacks_to_kill
  end

  def test_can_distribute_damage
    assert_equal 2, SCVs.new([12, 12, 2]).min_attacks_to_kill
  end

  def test_can_do_a_big_number
    assert_equal 42, SCVs.new([60]*9).min_attacks_to_kill
  end
  
  def test_doesnt_shoot_the_same_scv_twice
    assert_equal 2, SCVs.new([10, 1, 0]).min_attacks_to_kill
  end
end