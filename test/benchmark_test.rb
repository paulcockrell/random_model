$:.unshift '.';require File.dirname(__FILE__) + '/test_helper'
require 'benchmark'
class BenchmarkTest < Test::Unit::TestCase

  RUNS_PER_TEST = 1
  METHODS_TO_TEST = [:original, :by_order_by]

  def insert_artists(num)
    r = Benchmark.measure  {
      Artist.transaction do
        num.times do |i|
          Artist.connection.execute "INSERT INTO artists (name, views) VALUES ('artist#{i}', #{i})"
        end
      end}
      puts "-------------------------------------"
      puts "Time to do #{num} inserts: \n#{r.real} seconds"
  end

  context '1. A REALLY small number of artists' do
    setup do
      insert_artists(10)
    end
  
    should 'take time to fetch' do
      max_results = [nil, 2, 4, 6, 8, 10]
      results = get_benchmark_results max_results 
      print_results("10 total artists", results)
    end
  end

  context '2. A small number of artists' do
    setup do
      insert_artists(100)
    end
  
    should 'take less time to fetch' do
      max_results = [nil, 25, 50, 75, 100]
      results = get_benchmark_results max_results 
      print_results("100 total artists", results)
    end
  end

  context '3. A medium number of artists' do
    setup do
      insert_artists(1000)
    end
  
    should 'take less time to fetch' do
      max_results = [nil, 10, 100, 500, 1000]
      results = get_benchmark_results max_results 
      print_results("1,000 total artists", results)
    end
  end

  context '4. A large number of artists' do
    setup do
      insert_artists(10000)
    end
  
    should 'take less time to fetch' do
      max_results = [nil, 10, 100, 500, 1000]
      results = get_benchmark_results max_results 
      print_results("10,000 total artists", results)
    end
  end

  context '5. A really large number of artists' do
    setup do
      insert_artists(100000)
    end
  
    should 'take time to fetch' do
      max_results = [nil, 10, 100, 500, 1000]
      results = get_benchmark_results max_results 
      print_results("100,000 total artists", results)
    end
  end

  context '6. A humungus large number of artists' do
    setup do
      insert_artists(1000000)
    end
  
    should 'take time to fetch' do
      max_results = [nil, 10, 100, 500, 1000]
      results = get_benchmark_results max_results 
      print_results("1,000,000 total artists", results)
    end
  end

  def get_benchmark_results(max_results_arr)
    results = []
    max_results_arr.each do |max|
      METHODS_TO_TEST.each do |algorithm|
        r = Benchmark.measure  { RUNS_PER_TEST.times { Artist.random(max, algorithm) } }
        results << {:max_results => max, :algorithm => algorithm, :average_time => r.real / RUNS_PER_TEST}
      end
    end
    results
  end

  def print_results(title, results)
    puts "\n#{title}"
    fastest = {}
    results.each do |r|
      fastest[r[:max_results]] ||= [r[:algorithm], r[:average_time]]
      current_fastest = fastest[r[:max_results]]
      fastest[r[:max_results]] = [r[:algorithm], r[:average_time]] if r[:average_time] < current_fastest.second

      puts "max_results: #{r[:max_results] || 1}   average_time: #{r[:average_time]} seconds  algorithm: #{r[:algorithm]} "
    end
    fastest.each_pair do |max_results, r|
      puts "Fastest for max_results: #{max_results || 1} - #{r.first} #{r.second} seconds"
    end
  end

end