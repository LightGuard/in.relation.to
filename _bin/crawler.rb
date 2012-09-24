#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"

require_relative 'blog_entry'

require 'choice'
require 'anemone'
require 'pstore'

Choice.options do
  header 'Application options:'

  separator 'Required:'

  option :url, :required => true do
    short '-u'
    long '--url=<file>'
    desc 'The base url'
  end

  option :pattern, :required => false do
    short '-p'
    long '--pattern=<regexp>'
    desc 'Regular expression to limit the discovered pages'
  end

  option :out, :required => true do
    short '-o'
    long '--out=<file>'
    desc 'The name of the output-file'
  end

  separator 'Common:'

  option :help do
    short '-h'
    long '--help'
    desc 'Show this message.'
  end
end

class Crawler

  def initialize(base_url, pattern, output_file)
    #puts ARGV
    @base_url = base_url
    @pattern = Regexp.new(pattern)
    @output_file = output_file
  end

  def crawl
    store = PStore.new(@output_file)
    saved_posts = 0
    Anemone.crawl(@base_url) do |anemone|
      anemone.on_pages_like(@pattern) do |page|       
        puts "Processing #{page.url.to_s}"
        store.transaction do           
          store[page.url] = page.doc.to_s
          saved_posts += 1
        end
      end
    end
    puts "#{saved_posts} posts persisted"
  end
end

crawler = Crawler.new( Choice.choices.url, Choice.choices.pattern, Choice.choices.out )
crawler.crawl
