
bundle exec jekyll pagemaster books;
(cd _books;sed -i '' 's|\"\\uFEFFauthors\"|author|g' *.md);