BEGIN{FS="\t"}
{if(/Paulo/||/Ricardo/)
	{if($11 ~ "91")
		{print $11" "$5}}}