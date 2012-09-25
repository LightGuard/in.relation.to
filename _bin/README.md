# Importing in.relation.to

The scripts in this directory allow you to import the in.relation.to blog entries into awestruct.
They will crawl the site and save all *.lace urls into a Ruby PStore. From there erb files for the
awestruct site can be created.



## How to run the scripts

    # install bundler
    > gem install bundler

    # get your dependencies via bundler
    > bundler install

    # run the crawler
    > ./crawler.rb -u http://in.relation.to -p ".*\.lace" -o posts.pstore

    # run the importer
    > ./importer.rb -s posts.pstore -o <outdir>

    # alternative for experimenting when you don't want to download images (-ni) and assets (-na)
    > ./importer.rb -s posts.pstore -o <outdir> -ni -na

## Resources 

*  [bundler](http://gembundler.com/)

