(cd /Applications/calibre.app/Contents/MacOS;./calibredb catalog "/Users/Raman/Documents/GitHub/r-ym.github.io/_data/Current.csv")
bundle exec jekyll pagemaster books;
(cd _books;sed -i '' 's|authors|author|g' *.md;
for book in *; do
    if grep -l "\uFEFFauthor_sort" $book; then
        sed -i '' '2d;4,19d;21,23d' $book;
    fi
done
)