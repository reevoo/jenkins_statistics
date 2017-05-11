# Ensures the system is running
# and is connected to its database.
class Status
  PATH = "/healthcheck"

  def initialize(app)
    @app = app
  end

  def call(env)
    connected = db_connection

    if env["PATH_INFO"] == PATH
      status = connected ? 200 : 500
      [status, { "Content-Type" => "application/json; charset=utf-8" }, ["{\"db\": #{connected},\"app\": true}"]]
    else
      @app.call(env)
    end
  end

  private

  def db_connection
    StatsDb::CONNECTION.test_connection
  rescue
    false
  end
end
