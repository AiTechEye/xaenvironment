deprecated = {
	{
		replace = {"examobs:","materials:"},
		items = {
			"examobs:sugar",
			"examobs:sugar_with_glaze",
			"examobs:sponge_cake",
			"examobs:marzipan_rose",
			"examobs:candy1",
			"examobs:candy2",
			"examobs:candy3",
			"examobs:candy4",
			"examobs:candy5",
			"examobs:candy6",
			"examobs:gel",
			"examobs:gel_flowing",
			"examobs:gel2",
			"examobs:gel_flowing2"
		}
	}
}

for i1,v2 in pairs(deprecated) do
	for i,v in pairs(v2.items) do
		minetest.register_alias(v,v:gsub(v2.replace[1],v2.replace[2]))
	end
end