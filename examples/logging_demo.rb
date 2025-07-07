#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/rich"

puts "=== Rich Ruby Logging System Demo ===\n"

# Example 1: Basic Rich Logger
puts "1. Basic Rich Logger:"
logger = Rich::Logger.new

logger.debug("This is a debug message")
logger.info("Application started successfully")
logger.warn("This is a warning message")
logger.error("An error occurred")
logger.fatal("A fatal error occurred")

puts

# Example 2: Logger with different configurations
puts "2. Logger without timestamps and paths:"
console = Rich::Console.new
logger2 = Rich::Logger.new($stdout, show_time: false, show_path: false)

logger2.info("Clean log message without timestamp and path")
logger2.warn("Warning without extra info")
logger2.error("Error without extra info")

puts

# Example 3: Exception logging
puts "3. Exception Logging:"
logger3 = Rich::Logger.new

begin
  # Simulate an error
  result = 10 / 0
rescue ZeroDivisionError => e
  logger3.exception(e, message: "Division operation failed")
end

begin
  # Another error
  undefined_variable.some_method
rescue NameError => e
  logger3.exception(e, level: :warn)
end

puts

# Example 4: Styled logging
puts "4. Styled Logging:"
logger4 = Rich::Logger.new

logger4.styled(:info, "Success!", style: Rich::Style.new(color: "green", bold: true))
logger4.styled(:info, "Processing...", style: Rich::Style.new(color: "yellow"))
logger4.styled(:info, "Important", style: Rich::Style.new(color: "red", underline: true))

puts

# Example 5: Panel-style logging
puts "5. Panel-style Logging:"
logger5 = Rich::Logger.new

logger5.info_panel("System Status", "All systems operational\nMemory usage: 45%\nCPU usage: 12%")
logger5.warn_panel("Performance Warning", "High memory usage detected\nConsider optimizing your application")
logger5.error_panel("Database Error", "Connection to database failed\nRetrying in 30 seconds...")

puts

# Example 6: Class with Rich logging mixin
puts "6. Class with Rich Logging Mixin:"

class WebServer
  include Rich::Logging

  def start
    log_info("Starting web server...")
    log_info("Server listening on port 3000")
  end

  def stop
    log_warn("Stopping web server...")
    log_info("Server stopped gracefully")
  end

  def handle_request(path)
    log_debug("Handling request for #{path}")
    
    if path == "/error"
      log_error("404 Not Found: #{path}")
    else
      log_info("200 OK: #{path}")
    end
  end

  def crash_simulation
    begin
      raise RuntimeError, "Simulated server crash"
    rescue => e
      log_exception(e, message: "Server crashed unexpectedly")
    end
  end
end

server = WebServer.new
server.start
server.handle_request("/users")
server.handle_request("/api/data")
server.handle_request("/error")
server.crash_simulation
server.stop

puts

# Example 7: Different log levels demonstration
puts "7. Log Levels Demonstration:"
logger7 = Rich::Logger.new
logger7.level = Logger::DEBUG

logger7.debug("Debug: Variable x = #{42}")
logger7.info("Info: User login successful")
logger7.warn("Warn: Deprecated API usage detected")
logger7.error("Error: Failed to save user data")
logger7.fatal("Fatal: System out of memory")

# Set to WARN level
puts "\nWith log level set to WARN:"
logger7.level = Logger::WARN

logger7.debug("This debug message will not appear")
logger7.info("This info message will not appear")
logger7.warn("This warning will appear")
logger7.error("This error will appear")

puts

# Example 8: Logging performance
puts "8. Logging Performance Test:"
logger8 = Rich::Logger.new

puts "Logging 1000 messages..."
start_time = Time.now

1000.times do |i|
  logger8.debug("Debug message #{i}") if i % 100 == 0
  logger8.info("Info message #{i}") if i % 250 == 0
end

end_time = Time.now
logger8.info("Performance test completed in #{(end_time - start_time).round(3)} seconds")

puts "\n🎉 Rich logging demo completed!"