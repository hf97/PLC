BEGIN{FS="\t"}
NR>=3 && NR<=23 {print tolower($1)}