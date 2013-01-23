#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), 'jwave')

config = YAML.load(File.open(File.dirname(__FILE__) + '/config.yml'))
Jwave::Updater.new(config).update
