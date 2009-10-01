##require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'


class WorktimeTest < ActiveSupport::TestCase

  fixtures :worktimes

  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  test "evaluation of exclutions (See Worktime.not_reserved_hours(day)) " do
    w = Worktime.new

    start = 8
    stop = 16   
    exclusions = [[10, 11], [ 8,  9], [12, 13]]

    assert_equal [[start, stop]], w.available_periods(start, stop, [])
    assert_equal [[start, start+1], [start+2, stop] ], w.available_periods(start, stop, [[start + 1, start + 2]])

    assert_equal [ [9, 10], [11, 12], [13, 16]], w.available_periods(start, stop, exclusions)
    assert_equal [], w.available_periods(12, 13, exclusions)
    assert_equal [], w.available_periods(12, 12, exclusions)


    assert_equal [[12,13]], w.available_periods(12, 14, [[13,15]])
    assert_equal [[1,3]], w.available_periods(1, 3, [[5,8]])
    
  end

  test "worktime repetitions" do
    w = Worktime.new({:start_date => '2009-01-01', :end_date => '2010-01-01', :since => '2009-01-01 09:10', :until => '2010-01-01 09:50'})
    w.repetition = Worktime::ONCE

    assert !w.day_in_repetition?('2000-01-01')

    assert w.day_in_repetition?('2009-01-01')
    assert !w.day_in_repetition?('2009-02-01')

    w.repetition = Worktime::EVERY_WEEK

    assert w.day_in_repetition?('2009-01-01')
    assert w.day_in_repetition?('2009-02-05')
    assert !w.day_in_repetition?('2009-02-06')

    w.repetition = Worktime::EVERY_2_WEEKS

    assert w.day_in_repetition?('2009-01-01')
    assert w.day_in_repetition?('2009-01-15')
    assert w.day_in_repetition?('2009-01-29')
    assert !w.day_in_repetition?('2009-01-08')
    assert !w.day_in_repetition?('2009-01-09')


    w.repetition = Worktime::EVERY_MONTH_DAY

    assert w.day_in_repetition?('2009-01-01')
    assert w.day_in_repetition?('2009-02-01')
    assert w.day_in_repetition?('2009-05-01')
    assert !w.day_in_repetition?('2009-01-02')
    assert !w.day_in_repetition?('2009-01-03')


    w.repetition = Worktime::EVERY_DAY_OF_WEEK_IN_MONTH

    assert w.day_in_repetition?('2009-01-01')
    assert w.day_in_repetition?('2009-02-05')
    assert w.day_in_repetition?('2009-03-05')
    assert !w.day_in_repetition?('2009-01-02')
    assert !w.day_in_repetition?('2009-01-03')

    w.start_date = '2009-01-11'

    assert w.day_in_repetition?('2009-01-11')
    assert w.day_in_repetition?('2009-02-8')
    assert w.day_in_repetition?('2009-03-8')
    assert !w.day_in_repetition?('2009-01-02')
    assert !w.day_in_repetition?('2009-01-03')

    ## 
    w.start_date = '2009-01-05'
    w.repetition = Worktime::ONCE
    assert !w.day_in_repetition?('2000-01-01')
    assert !w.day_in_repetition?('2009-01-01')
    assert w.day_in_repetition?('2009-01-05')
    assert !w.day_in_repetition?('2009-02-01')

    w.repetition = Worktime::EVERY_WEEK

    assert w.day_in_repetition?('2009-01-05')
    assert w.day_in_repetition?('2009-01-12')
    assert !w.day_in_repetition?('2009-02-05')
    assert w.day_in_repetition?('2009-02-02')

    w.repetition = Worktime::EVERY_2_WEEKS

    assert !w.day_in_repetition?('2009-01-01')
    assert w.day_in_repetition?('2009-01-05')
    assert w.day_in_repetition?('2009-01-19')
    assert w.day_in_repetition?('2009-02-02')
    assert !w.day_in_repetition?('2009-01-08')
    assert !w.day_in_repetition?('2009-01-09')


    w.repetition = Worktime::EVERY_MONTH_DAY

    assert !w.day_in_repetition?('2009-01-01')
    assert !w.day_in_repetition?('2009-02-01')
    assert w.day_in_repetition?('2009-05-05')
    assert !w.day_in_repetition?('2009-01-02')
    assert !w.day_in_repetition?('2009-01-03')


    w.repetition = Worktime::EVERY_DAY_OF_WEEK_IN_MONTH

    assert w.day_in_repetition?('2009-01-05')
    assert w.day_in_repetition?('2009-02-02')
    assert w.day_in_repetition?('2009-03-02')
    assert w.day_in_repetition?('2009-04-06')
    assert !w.day_in_repetition?('2009-01-02')
    assert !w.day_in_repetition?('2009-01-03')

    w.start_date = '2009-01-11'

    assert w.day_in_repetition?('2009-01-11')
    assert w.day_in_repetition?('2009-02-08')
    assert w.day_in_repetition?('2009-03-08')
    assert !w.day_in_repetition?('2009-01-02')
    assert !w.day_in_repetition?('2009-01-03')

    ## 
     
    w.start_date = '2009-09-28'
    w.end_date = '2010-09-28'
    w.repetition = Worktime::EVERY_WEEK
    assert w.day_in_repetition?('2009-10-05')
    
  end
  
end
