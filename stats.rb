#!/usr/bin/env ruby

current_dir = File.expand_path(File.dirname(__FILE__))
puts current_dir
Dir.chdir(File.expand_path("../plugins", current_dir))

$globprodloc = 0
$globtestloc = 0

def stats(name)
  prodloc = %x(find init.rb app lib config -type f -name "*.rb" 2>/dev/null | xargs wc -l).lines.map(&:to_i).inject(&:+) || 0
  testloc = %x(find test spec -type f -name "*.rb" 2>/dev/null | xargs wc -l).lines.map(&:to_i).inject(&:+) || 0
  $globtestloc += testloc
  $globprodloc += prodloc
  render name, prodloc, testloc
end

def ratio(prodloc, testloc)
  (testloc.to_f / prodloc).round(1)
end

def render(title, prodloc, testloc)
  puts "#{title} | test=#{testloc} / prod=#{prodloc} | code-to-test-ratio=1:#{ratio prodloc, testloc}"
end

Dir.glob("redmine_*").each do |plugin|
  Dir.chdir(plugin) do
    stats File.basename(plugin)
  end
end

render "TOTAL", $globprodloc, $globtestloc
