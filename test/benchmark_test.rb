$:.unshift '.';require File.dirname(__FILE__) + '/test_helper'
require 'benchmark'
class BenchmarkTest < Test::Unit::TestCase

  RUNS_PER_TEST = 1000
  METHODS_TO_TEST = [:random_ids_via_hash, :random_ids_via_shuffle]

  # context '1. A REALLY small number of artists' do
  #   setup do
  #     10.times { |i| Artist.make! }
  #   end
  
  #   should 'take time to fetch' do
  #     max_results = [nil, 2, 4, 6, 8, 10]
  #     results = get_benchmark_results max_results 
  #     print_results("10 total artists", results)
  #   end
  # end

  # context '2. A small number of artists' do
  #   setup do
  #     100.times { |i| Artist.make! }
  #   end
  
  #   should 'take less time to fetch' do
  #     max_results = [nil, 25, 50, 75, 100]
  #     results = get_benchmark_results max_results 
  #     print_results("100 total artists", results)
  #   end
  # end

  # context '3. A medium number of artists' do
  #   setup do
  #     1000.times { |i| Artist.make! }
  #   end
  
  #   should 'take less time to fetch' do
  #     max_results = [nil, 10, 100, 500, 1000]
  #     results = get_benchmark_results max_results 
  #     print_results("1,000 total artists", results)
  #   end
  # end

  # context '4. A large number of artists' do
  #   setup do
  #     10000.times { |i| Artist.make! }
  #   end
  
  #   should 'take less time to fetch' do
  #     max_results = [nil, 10, 100, 500, 1000]
  #     results = get_benchmark_results max_results 
  #     print_results("10,000 total artists", results)
  #   end
  # end

  # context '5. A really large number of artists' do
  #   setup do
  #     100000.times { |i| Artist.make! }
  #   end
  
  #   should 'take time to fetch' do
  #     max_results = [nil, 10, 100, 500, 1000]
  #     results = get_benchmark_results max_results 
  #     print_results("100,000 total artists", results)
  #   end
  # end

  context 'a smaller array of id hashes' do
    setup do
      @array = []
      1000.times { |i| @array << {'id' => i} }
    end
  
    should 'take less time to fetch' do
      puts "1,000 elements\n"
      call_for_each([1, 5, 10, 50, 100, 500, 1000])
    end
  end

  context 'a medium array of id hashes' do
    setup do
      @array = []
      5000.times { |i| @array << {'id' => i} }
    end
  
    should 'take less time to fetch' do
      puts "5,000 elements\n"
      call_for_each([1, 5, 10, 50, 100, 500, 1000, 5000])
    end
  end

  context 'a large array of id hashes' do
    setup do
      @array = []
      10000.times { |i| @array << {'id' => i} }
    end
  
    should 'take less time to fetch' do
      puts "10,000 elements\n"
      call_for_each([1, 5, 10, 50, 100, 500, 1000, 5000, 10000])
    end
  end

  def call_for_each(max_results_arr)
    max_results_arr.each do |max|
      puts " "
      METHODS_TO_TEST.each do |algorithm|
        r = Benchmark.measure { RUNS_PER_TEST.times{ send(algorithm, @array, max) } }
        avg = (r.real / RUNS_PER_TEST).round(6)
        puts "#{max || 1} avg_time: #{avg} #{algorithm} "
      end
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
    puts "\n#{title}\n"
    fastest = {}
    results.each do |r|
      fastest[r[:max_results]] ||= [r[:algorithm], r[:average_time]]
      current_fastest = fastest[r[:max_results]]
      fastest[r[:max_results]] = [r[:algorithm], r[:average_time]] if r[:average_time] < current_fastest.second

      #puts "max_results: #{r[:max_results] || 1}   average_time: #{r[:average_time]} seconds  algorithm: #{r[:algorithm]} "
    end
    puts "\n"
    fastest.each_pair do |max_results, r|
      puts "Fastest for max_results: #{max_results || 1} - #{r.first} #{r.second} seconds"
    end
  end




      def random_ids_via_shuffle(results, max_items)
        results.shuffle[0,max_items].collect { |h| h['id'] }
      end

      def random_ids_via_hash(results, max_items)
        ids = {}
        while ids.length < max_items && ids.length < results.length 
          rand_index = rand( results.length )
          ids[rand_index] = results[rand_index]["id"]
        end
        ids.values
      end


      def random_ids_via_partial_fisher_yates(results, max_items)
        i = 0
        # perform swaps only as far as we need
        while i < max_items && i < results.length
          # select only from portion of set past current element
          rand_i = i + rand( results.length - i ) 
          # swap current element, and picked element
          tmp = results[rand_i]
          results[rand_i] = results[i]
          results[i] = tmp
          i += 1
        end
        results[0, max_items].collect { |h| h['id'] }
      end

      def random_ids_via_set(results, max_items)
        ids = Set.new
        while ids.length < max_items && ids.length < results.length 
          ids << results[rand( results.length )]["id"]
        end
        ids.to_a
      end


end