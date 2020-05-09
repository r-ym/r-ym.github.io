(cd /Applications/calibre.app/Contents/MacOS;./calibredb catalog "/Users/rym/Documents/GitHub/r-ym.github.io/_data/Current.csv")
(python3 cutter.py;)
bundle exec jekyll pagemaster books;
rm _data/Currents.csv;