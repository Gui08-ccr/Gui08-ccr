local cfg = {}

cfg.groups = {
	["Owner"] = {
		"admin.perm",
		"staff.chat",
		"chamado.adm",
		"player.blips",
		"player.spec"
	},
	["Mod"] = {
		"mod.perm",
		"staff.chat",
		"chamado.adm",
		"player.blips",
		"player.spec"
	},
	["Suporte"] = {
		"suporte.perm",
		"staff.chat",
		"chamado.adm"
	},
	["Platina"] = {
		_config = {
			title = "Platina",
			gtype = "vip"
		},
		"platina.perm",
		"mochila.vip"
	},
	["Ouro"] = {
		_config = {
			title = "Ouro",
			gtype = "vip"
		},
		"ouro.perm",
		"mochila.vip"
	},
	["Prata"] = {
		_config = {
			title = "Prata",
			gtype = "vip"
		},
		"prata.perm"
	},
	["Bronze"] = {
		_config = {
			title = "Bronze",
			gtype = "vip"
		},
		"bronze.perm"
	},
}

cfg.users = {
	[1] = { "Owner" }
}

cfg.selectors = {}

return cfg