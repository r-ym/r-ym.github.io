(cd /Applications/calibre.app/Contents/MacOS;./calibredb catalog "/Users/raman/Github/r-ym.github.io/_data/bookish.csv")
(cd _data;
awk     'FNR==1 {CNT=split(COLS, CNo, ",")}                             # get desired columns into array
                {for (i=2; i<=NF; i+=2) {                               # every second field is one inside double quotes
                         gsub (/,/, "\001", $i)                         # replace every comma in quoted field by something
                        }
                 split ($0, TMP, ",")                                   # now get the comma separated fields into an temp array
                 $0=""
                 for (i=1; i<=CNT; i++) $0=$0 ($0?",":"") TMP[CNo[i]]   # rebuild $0 from this array using only COLS columns
                 gsub ("\001", ",")                                     # replace something back to commas
                }
         1                                                              # print new $0 string
        ' FS="\"" OFS="\"" COLS=2,19 bookish.csv >> books.csv;
        rm bookish.csv
	)
bundle exec jekyll pagemaster books;