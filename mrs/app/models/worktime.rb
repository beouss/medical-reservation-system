class Worktime < ActiveRecord::Base
  belongs_to :place
  belongs_to :doctor, :class_name => "User"
  
  ONCE = 0
  EVERY_WEEK = 1
  EVERY_2_WEEKS = 2
  EVERY_MONTH_DAY = 3
  EVERY_DAY_OF_WEEK_IN_MONTH = 4

  REPETITIONS  = [
                  ["No repetition", ONCE], 
                  ["Every week", EVERY_WEEK], 
                  ["Every two weeks",EVERY_2_WEEKS], 
                  ["At this day (e.g 12) once in month", EVERY_MONTH_DAY],
                  ["At this day of week (e.g monday) once in month", EVERY_DAY_OF_WEEK_IN_MONTH]
                 ]

  include Period::Format
  include Period::Util

  def validate
    if since > self.until or start_date > end_date
        errors.add("since_or_until", "since has to be less then until") 
    end

    if since == self.until 
      b = since.hour > self.until.hour 
      c = since.hour == self.until.hour and since.min > self.until.min
      if  b or c
        errors.add("since_or_until", "since has to be less then until") 
      end
    end
  end
    

  #  Example of evaluation:
  # 
  #  Absences in day                       Minutes from 00:00
  #  10:20 - 11:30    (1:10)    -> 70      10*60+20 - 11*60+30
  #
  #  Visits reservations
  #  8:00  - 8:30     (0:30)    -> 30      8 *60       8*60+30
  #  12:45 - 13:00    (0:15)    -> 15      12*60+45   13*60 
  #  
  #  Worktime
  #  8:00  - 16:00    (8:00)    -> 480
  #
  #  Not reserved hours
  #  8:30  - 10:20    (1:50)    -> 110
  #  11:30 - 12:45    (1:15)    -> 75
  #  13:00 - 16:00    (3:00)    -> 180
  #
  #         480-(70+30+15) = 110+75+180   //  365=365
  #
  # Return data format [[start of period in minutes from 00:00, end of period in minutes from 00:00], ...]
  # data for above example:
  # [ [8*60+30, 10*60+20], [11*60+30, 12*60+45], [13*60, 16*60]]
  # see worktime_test.rb
  def not_reserved_hours(day)
    return [] unless day_in_repetition?(day)

    absences = Absence.new.absences_at_day(doctor.id, day)
    reservations = VisitReservation.new.reservations_at_day(doctor.id, day)    
    visits = Visit.new.visits_at_day(doctor.id, day)
    
    logger.info " -          -- - - - -- -    - - -  - -  "
    # make array [[start, stop], ...]
    # from abcenses ...    
    exclusions = absences.collect { |a| logger.info(a.since.to_date < day.to_date ? 0 : Period::Util::day_minutes(a.since.to_time) ).to_s
      logger.info(a.until.to_date > day.to_date ? 24 * 60 : Period::Util::day_minutes(a.until.to_time) ).to_s
      logger.info a.since.to_date 
      logger.info a.until.to_date
      logger.info day
      [ a.since.to_date < day.to_date ? 0 : Period::Util::day_minutes(a.since.to_time) ,
        a.until.to_date > day.to_date ? 24 * 60 : Period::Util::day_minutes(a.until.to_time) 
      ] 
    }
    logger.info exclusions.class
    # ... and from reservations
    exclusions.concat reservations.collect { |a| [ a.since.to_date < day.to_date ? 0 : Period::Util::day_minutes(a.since.to_time) ,a.until.to_date > day.to_date ? 24 * 60 : Period::Util::day_minutes(a.until.to_time) ] }
    # ... and from visits
    exclusions.concat visits.collect { |a| [ a.since.to_date < day.to_date ? 0 : Period::Util::day_minutes(a.since.to_time) ,a.until.to_date > day.to_date ? 24 * 60 : Period::Util::day_minutes(a.until.to_time) ] }
    logger.info " ================ EXCLUSIONS ===== "
    logger.info exclusions.each {|e|  logger.info "[" + e[0].to_s + ", " + e[1].to_s + "]" }
    logger.info " ================ DAY_MINUTES SINCE, UNTIL ===== "
    logger.info Period::Util::day_minutes(self.since.to_time).to_s + ", " + Period::Util::day_minutes(self.until).to_s
    
    a = available_periods( Period::Util::day_minutes(self.since.to_time), Period::Util::day_minutes(self.until), exclusions)      
    logger.info "================ AVAILALBE ======"
    logger.info a
    a
  end

  # Choose all worktimes for parameters
  def self.available_worktimes(place_id, speciality_id, doctor_id, start_date)
    query = "select * from worktimes w"
    conditions = []
    parameters = []
    if place_id
      conditions << "w.place_id = ?"
      parameters << place_id
    end
    if speciality_id 
      conditions <<  " w.doctor_id in (select u.id from users u, doctor_specialities ds where ds.doctor_id = u.id and ds.speciality_id = ?) "
      parameters << speciality_id
    end
    if doctor_id
      conditions <<  " w.doctor_id = ? "
      parameters << doctor_id
    end

    if start_date 
      conditions <<  " ? between w.start_date and w.end_date "
      parameters << start_date
    end
    
    if conditions.count > 0
      query += " where " 
      for c in conditions
        query += c + " and "
      end
      query_with_params = [ query[0, query.length - 5] ]
      query_with_params.concat parameters
    else
      query_with_params = [query]
    end
    worktimes = Worktime.find_by_sql query_with_params    
  end

  # Choose all worktimes and return not_reserver
  def self.not_reserved_worktimes(day, doctor_id, place_id, speciality_id)
    hours = []
    for worktime in available_worktimes(place_id, speciality_id, doctor_id, day)
      hours.concat worktime.not_reserved_hours(day)
    end
    hours
  end

  # check absences and visits at this time for this doctor
  def self.available?(date_since, date_until, doctor_id, place_id, speciality_id)     
    logger.info " ================ SELF.SINCE ===== " + Period::Util::day_minutes(date_since).to_s + "    " +  Period::Util::day_minutes(date_until).to_s
    nr = Worktime.not_reserved_worktimes(date_since.to_date, doctor_id, place_id, speciality_id)
    # eg. nr == [[1040, 2030], [3000,4300]]
    ok = false
    nr.each {|r| logger.info "--------------> " + r[0].to_s + "  " +  r[1].to_s }   
    nr.each {|r| ok = true if r[0] <= Period::Util::day_minutes(date_since) and r[1] >= Period::Util::day_minutes(date_until) }
    ok
  end
  
  # Return true if day is one of worktime repetition
  def day_in_repetition?(day)
    logger.info ">>>>>>>>>>>>>>>>>>> day_in_repetition? " + self.repetition.to_s + " " + Worktime::EVERY_WEEK.to_s
    if day.to_date < self.start_date or day.to_date > self.end_date
      logger.info " ===== RANGE !!! ===== "
      false
    else
      if self.repetition == Worktime::ONCE then
        day.to_date == self.start_date
      elsif self.repetition == Worktime::EVERY_WEEK 
        day.to_date.wday == self.start_date.wday
      elsif self.repetition == Worktime::EVERY_2_WEEKS 
        (day.to_date.yday - self.start_date.to_date.yday) % 14 == 0
      elsif self.repetition == Worktime::EVERY_MONTH_DAY
        day.to_date.mday == self.start_date.mday 
      elsif self.repetition == Worktime::EVERY_DAY_OF_WEEK_IN_MONTH
        # E.g. every second friday in month 
        wday = self.start_date.wday
        mday = self.start_date.mday
        which = mday / 7
        day.to_date.wday == wday and day.to_date.mday / 7 == which
      else
        false
      end
    end
  end


  # Returns table of periods from start to stop without exclusions
  # start - minutes from day start
  # stop - minutes from day start
  # exclusions - table with pairs [start, stop]
  def available_periods(start, stop, exclusions)
    if exclusions.count == 0 
      [[start, stop]]
    elsif start == stop
      []
    else
      a = []
      exclusions.sort!
      #for i in (0..(exclusions.count-1))
      i = 0
      e_count = exclusions.count
      while i < e_count
        e = exclusions[i]
        if e[0] <= start 
          start = e[1] < start ? start : e[1]
          i = i + 1
        else
          a << [start, e[0] > stop ? stop : e[0]]
          if e[1] > stop 
            start = stop # To prevent last array enlarging (*)
            break
          else
            start = e[1]
          end
        end
      end
      # (*)
      if start < stop
        a << [start, stop]
      end
      a
    end
  end
  

  def format_day_minutes_range(minutes_range)
    s = minutes_range [0]
    e = minutes_range [1]
    t1 = Time.gm(2000, 1, 1, s / 60, s % 60, 0)
    t2 = Time.gm(2000, 1, 1, e / 60, e % 60, 0)
    t1.strftime("%H:%M") + ".." + t2.strftime("%H:%M")
  end
end
