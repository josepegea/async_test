#!/usr/bin/env ruby

$program = ARGV.shift
$title = ARGV.shift || $program

system("bundle exec #{$program} | bundle exec show_bars.rb #{$title}&")
