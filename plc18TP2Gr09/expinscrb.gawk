BEGIN{FS="\t"}
/Individual/ && /Valongo/ {print $1}