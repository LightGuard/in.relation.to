#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"

require_relative 'blog_entry'

require 'choice'
require 'pstore'
require 'nokogiri'

Choice.options do
  header 'Application options:'

  separator 'Required:'

  option :pstore, :required => true do
    short '-s'
    long '--store=<file>'
    desc 'The PStore file'
  end

  option :outdir, :required => true do
    short '-o'
    long '--out=<dir>'
    desc 'The name of the output directory'
  end

  separator 'Common:'

  option :help do
    short '-h'
    long '--help'
    desc 'Show this message.'
  end
end

class Importer

  def initialize(import_file, output_dir)
    @import_file = import_file
    @output_dir = output_dir
  end


  #doc = Nokogiri::XML(File.open(@import_file))
  #puts doc
  #root.get_elements( 'channel/item' ).each do |item|
  #  puts "foo"
  # import_item( item )
  #end

  def import_posts
    posts = PStore.new(@import_file)
    posts.transaction(true) do  # begin read-only transaction, no changes allowed
      posts.roots.each do |post_url|
        puts "key: #{post_url}"
        puts "value: #{posts[post_url]}"
      end
    end
  end

  private

  def import_post
  end

  def import_images
  end

  def import_attachment
  end
end

importer = Importer.new( Choice.choices.pstore, Choice.choices.out )
importer.import_posts
