BEGIN{FS="\t"}
NR>=7 && NR<=17 {print $1" "$2}