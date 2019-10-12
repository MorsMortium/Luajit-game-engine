return function(args)
	local AllWindowRenders, Globals = args[1], args[2]
	local Globals = Globals.Library.Globals
	local pcall, loadstring, write = Globals.pcall, Globals.loadstring,
	Globals.write

	local GiveBack = {}

	GiveBack.Inputs = {}
	GiveBack.Inputs.Up = {}
	GiveBack.Inputs.Down = {}
	function GiveBack.Inputs.Down.Escape(AllInputsSpace)
		return true
	end
	function GiveBack.Inputs.Down.Return(AllInputsSpace)
		if pcall(loadstring(AllInputsSpace.Text)) then
			AllInputsSpace.Text = ""
		end
	end
	function GiveBack.Inputs.Down.Delete(AllInputsSpace)
		AllInputsSpace.Text = ""
		write("\n")
	end
	function GiveBack.Inputs.Down.P(AllInputsSpace)
		write(AllWindowRenders.Space.FramesPerSecond, " FramesPerSecond\n")
	end
	function GiveBack.Inputs.Down.Backspace(AllInputsSpace)
		AllInputsSpace.Text = AllInputsSpace.Text:sub(1, -2)
		write(AllInputsSpace.Text, "\n")
	end
	return GiveBack
end
