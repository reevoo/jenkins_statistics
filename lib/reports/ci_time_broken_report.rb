class CITimeBrokenReport < CIReportBase

  attr_accessor :time_broken_for, :time_passed_for, :previous_build

  def present
    generate

    DashboardUpdater.new(
      "#{project}-time-green-red",
      {"title" => "Green/Red time", "text" => "green:#{formated_time(time_passed_for)} red:#{formated_time(time_broken_for)}"}
    ).update
  end

  private

  def builds_data
    @_build_data ||= builds_timestamps    
  end

  def builds_timestamps
    builds_timestamps = []
    builds.each do |build|
      builds_timestamps << {
        time: build['timestamp'].to_i/1000,
        result: build['result']
      }
    end
    builds_timestamps.sort_by{ |b| b[:time]}
  end

  def generate
    self.time_broken_for = 0
    self.time_passed_for = 0

    builds_timestamps.each_with_index do |build, index|

      if self.previous_build
        if self.previous_build[:result] == 'SUCCESS' && build[:result] == 'SUCCESS'
          self.time_passed_for += (build[:time] - self.previous_build[:time])
        end
        if self.previous_build[:result] == 'FAILURE' && build[:result] == 'FAILURE'
          self.time_broken_for += (build[:time] - self.previous_build[:time])
        end
      end
      self.previous_build = build
    end
  end

  def formated_time(t)
    mm = t.divmod(60)
    hh, mm = mm.divmod(60)
    dd, hh = hh.divmod(24)
    "%dd,%dh,%dm "% [dd, hh, mm]
  end
end