# frozen_string_literal: true

#require "bundler/gem_tasks"
require "rake/testtask"


task default: :test

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end


task :doc do
    sh 'rake -C doc -f Rakefile build'
end


task :run do
    sh 'exe/umu -i'
end
