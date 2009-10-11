#!/usr/bin/env ruby

$: << ENV["TM_SUPPORT_PATH"] + "/lib"

require 'textmate'
require 'tm/executor'
require 'tm/save_current_document'

require File.dirname(__FILE__) + '/formatter'

TextMate.save_current_document

unless ENV['PIG_HOME'] =~ /^\s*$/
  formatter = Formatter.new

  TextMate::Executor.run("#{ENV['PIG_HOME']}/bin/pig", '-x', 'local', ENV["TM_FILEPATH"]) do |line, type|
    formatter.format_line(line, type)
  end
else
  puts "PIG_HOME not set"
end