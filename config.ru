require_relative 'web/stats_web'
require_relative 'lib/status'

use Status
run StatsWeb.new
