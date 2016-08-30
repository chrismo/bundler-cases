#!/usr/bin/env ruby

require 'bundler/setup'

require_relative 'lib/bundler_case'
require 'rainbow'

class BundlerCase
  class Fail
    def initialize(fn, title, message)
      @fn = fn.sub(__dir__, '')
      @title = title
      @message = message
    end

    def to_s
      Rainbow("FAILED: #{@title || @fn} - #{@message}").red
    end
  end

  class Pass
    def initialize(fn, title)
      @fn = fn.sub(__dir__, '')
      @title = title
    end

    def to_s
      Rainbow("Passed: #{@title || @fn}").green
    end
  end

  class Runner
    def puts_title(title)
      width = [title.length, 80].max
      puts '=' * width
      puts title.center(width)
      puts '=' * width
    end

    def execute_case(fn)
      c = eval(File.read(fn))
      title = File.basename(fn, '.rb').gsub(/_/, ' ').split(/ /).map(&:capitalize).join(' ')
      puts_title(title)
      if c
        passed = c.test
        if passed then
          Pass.new(fn, title)
        else
          puts c.failures.join("\n")
          Fail.new(fn, title, c.failures.join("\n"))
        end
      else
        Fail.new(fn, nil, 'No BundlerCase found')
      end
    end

    def execute_cases(filter)
      results = []
      Dir[File.expand_path('cases/**/*.rb', __dir__)].each do |fn|
        next if fn !~ /#{filter}/ if filter
        begin
          results << execute_case(fn)
        rescue => e
          puts "ERROR running #{fn}: #{[e.message, e.backtrace].join("\n")}"
        end
      end
      pass, fail = results.partition { |r| r.is_a?(Pass) }
      pass.concat(fail).each { |r| puts r.to_s }
    end
  end
end

BundlerCase::Runner.new.execute_cases(filter = ARGV[0])
