$:.unshift '.';require File.dirname(__FILE__) + '/test_helper'

class BenchmarkTest < Test::Unit::TestCase

  context 'A large number of artists' do
    setup do
      100000.times { |i| Artist.make! }
      puts "A large number of artists: 100000"
    end
  
    should 'take time to fetch' do
      require 'benchmark'
      Benchmark.bm do |x|
      	total_runs = 100
        r1 = x.report { total_runs.times { Artist.random } }
        r2 = x.report { total_runs.times { Artist.random(10) } }
        r3 = x.report { total_runs.times { Artist.random(100) } }
        r4 = x.report { total_runs.times { Artist.random(1000) } }
        puts "Artist.random average: #{r1.real / total_runs} seconds"
        puts "Artist.random(10) average: #{r2.real / total_runs} seconds"
        puts "Artist.random(100) average: #{r3.real / total_runs} seconds"
        puts "Artist.random(1000) average: #{r4.real / total_runs} seconds"
      end
    end
  end

  context 'A small number of artists' do
    setup do
      100.times { |i| Artist.make! }
      puts "A small number of artists: 100"
    end
  
    should 'take less time to fetch' do
      require 'benchmark'
      Benchmark.bm do |x|
      	total_runs = 100
        r1 = x.report { total_runs.times { Artist.random } }
        r2 = x.report { total_runs.times { Artist.random(10) } }
        r3 = x.report { total_runs.times { Artist.random(100) } }
        puts "Artist.random average: #{r1.real / total_runs} seconds"
        puts "Artist.random(10) average: #{r2.real / total_runs} seconds"
        puts "Artist.random(100) average: #{r3.real / total_runs} seconds"
      end
    end
  end

  context 'A REALLY small number of artists' do
    setup do
      10.times { |i| Artist.make! }
      puts "A REALLY number of artists: 10"
    end
  
    should 'take time to fetch' do
      require 'benchmark'
      Benchmark.bm do |x|
      	total_runs = 100
        r1 = x.report { total_runs.times { Artist.random } }
        r2 = x.report { total_runs.times { Artist.random(5) } }
        r3 = x.report { total_runs.times { Artist.random(10) } }
        puts "Artist.random average: #{r1.real / total_runs} seconds"
        puts "Artist.random(5) average: #{r2.real / total_runs} seconds"
        puts "Artist.random(10) average: #{r3.real / total_runs} seconds"
      end
    end
  end

end