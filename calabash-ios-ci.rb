#!/usr/bin/ruby
require "getoptlong"

getoptlong = GetoptLong.new(
   [ '--target',  '-t', GetoptLong::REQUIRED_ARGUMENT ],
   [ '--log-file', '-l', GetoptLong::REQUIRED_ARGUMENT ],
   [ '--source-root', '-r', GetoptLong::REQUIRED_ARGUMENT ]

)

def printUsage()
    puts "Usage:"
    puts "calabash-ios.rb --source-root source_path --target project_target"
end

source_root = nil
target = nil
arch = "iphonesimulator"
configuration = "Hockey"
log_file = nil

begin
  getoptlong.each do |opt, arg|
    case opt
      when "--source-root"
        source_root = arg
      when "--target"
        target = arg
      when "--log-file"
        log_file = arg
    end
  end
rescue StandardError=>my_error_message
       puts
       puts my_error_message
       printUsage()
       puts
       exit 1
end

if target.nil? or source_root.nil?
  puts "You must specify target and source root"
  printUsage
  exit 1
end
app_path = "#{source_root}/build/#{configuration}-#{arch}/#{target}.app"
%x[ rm -rf #{app_path}]

cedar_test_target = "cd #{source_root} && xcodebuild -target '#{target}' -sdk #{arch} -configuration #{configuration} clean build "
cedar_test_target_exit_code = system(cedar_test_target)

if cedar_test_target_exit_code
  puts "Calabash target build succeeded"
  puts
else
  puts "Calabash target build failed"
  exit 1
end

log_file = "/tmp/calabash-#{target}-#{Time.now.to_i}.log" if log_file.nil?

test_command = "cucumber  --tags @native_checkout_nc -f json -o ch.json -f html -o ch.html"

system("APP_BUNDLE_PATH='#{app_path}' OS=ios5 #{test_command} -o #{log_file} --no-color --require features")

grep_exit_code = system("grep -q \"failed\" #{log_file}")

File.open(log_file, 'r') do |f1|
  while line = f1.gets
    puts line
  end
end

if grep_exit_code
  puts "Cucumber failed"
  exit 1
end
exit 0