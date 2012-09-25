#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"

require_relative 'blog_entry'

require 'choice'
require 'pstore'
require 'nokogiri'
require 'date'
require 'fileutils'
require 'net/http'
require 'uri'

Choice.options do
  header 'Application options:'

  separator 'Required:'

  option :pstore, :required => true do
    short '-s'
    long '--store=<file>'
    desc 'The PStore file containing the spidered HTML'
  end

  option :outdir, :required => true do
    short '-o'
    long '--out=<dir>'
    desc 'The name of the output directory'
  end

  option :skip_images, :required => false do
    short '-ni'
    long '--no-images'
    desc 'Wether image processing should be skipped'
  end

  option :skip_assets, :required => false do
    short '-na'
    long '--no-assets'
    desc 'Wether asset processing should be skipped'
  end

  separator 'Common:'

  option :help do
    short '-h'
    long '--help'
    desc 'Show this message.'
  end
end

class Importer

  BASE_URL = "http://in.relation.to"

  def initialize(import_file, output_dir, skip_image_procesing, skip_asset_procesing)
    @skip_image_procesing = skip_image_procesing.nil? ? false : true
    @skip_asset_procesing = skip_asset_procesing.nil? ? false : true
    @import_file = import_file
    @output_dir = output_dir
    @image_dir = @output_dir + '/images'
    FileUtils.mkdir_p( @image_dir )
  end

  def import_posts
    successful_import = 0
    failed_import = 0
    failures = Hash.new
    posts = PStore.new(@import_file)
    posts.transaction(true) do
      posts.roots.each do |lace|

        # create a blog entry and parse its content
        blog_entry = BlogEntry.new
        blog_entry.lace = lace
        begin
          import_post(blog_entry, posts[lace])
          write_file(blog_entry)
          successful_import += 1
        rescue => e
          failed_import += 1
          failures[lace] = e
        end
      end
    end
    puts "Successfull imports #{successful_import}"
    puts "Failed imports #{failed_import}"
    #puts failures
  end

  private

  def import_post(blog_entry, content)
    doc = Nokogiri::HTML(content)

    # process main contnet
    blog_entry.content = doc.search('#documentDisplay')

    # title and wiki title
    title_link = doc.css('h1.documentTitle > a')
    blog_entry.title = title_link.text
    blog_entry.slug = title_link.attr('href').to_s.sub('/Bloggers/', '')

    # author and blogger name
    author_link = doc.css('div.documentCreatorHistory > div > a').first
    blog_entry.author = author_link.text
    blog_entry.blogger_name = author_link.attribute('href').to_s.sub('/Bloggers/', '')

    # creation date
    published_string = doc.css('div.documentCreatorHistory > div').first.text.strip.gsub(/Created:/, '').gsub(/\(.*/, '')
    blog_entry.date = DateTime.parse( published_string )

    # tags
    blog_entry.tags = doc.css('div.documentTags  a').map {|link| link.text.to_s}

    if(!@skip_image_procesing)
      import_images(blog_entry.content)
    end

    if(!@skip_asset_procesing)
      import_assets(doc)
    end
  end

  def import_images(content)
    content.css('img').map do |image|
      if (image['src'] =~ /http:\/\/in.relation.to\/service\/File/)
        # get the image
        url = URI.parse( image['src'] )
        res = Net::HTTP.start(url.host, url.port) {|http|
          http.get(url.path)
        }

        # just keep the image name (a number in our case)
        image_name = image['src'].split('/').last

        # write the image
        out = File.join( @image_dir, image_name )
        File.open( out, 'wb' ) do |f|
          f.write res.body
        end

        # adjust the image target
        # TODO - verify this is the correct path. Where and how do images go in awestruct
        image['src'] = "../../../images/" + image_name
      end
    end
  end

  def import_assets(doc)
    # attachements are in a table at the bottom of the post. Let's process the table first and then adjust the actual post content
#    doc.css('div.attachmentDisplay tr').map do |attachment_row|
#      attachment_row.css('a').map do |attachment_link|
#        if(a['href'] =~ //)
#        end
#      end
#    end
  end

  def write_file(blog_entry)
    out = File.join( @output_dir, blog_entry.file_name )
    File.open( out, 'w' ) do |f|
      f.puts blog_entry.to_erb
    end
  end
end

importer = Importer.new(Choice.choices.pstore, Choice.choices.outdir, Choice.choices.skip_images, Choice.choices.skip_asset_procesing)
importer.import_posts
