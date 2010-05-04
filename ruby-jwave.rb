#!/usr/bin/env ruby
require 'jwave'

config = YAML.load(File.open(File.dirname(__FILE__) + '/config.yml'))
Jwave::Updater.new(config).update
