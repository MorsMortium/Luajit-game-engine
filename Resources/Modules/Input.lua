return function(args)
	local AllWindowRenders = args[1]
	local GiveBack = {}

	function GiveBack.Reload(args)
		AllWindowRenders = args[1]
  end

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
		io.write("\n")
	end
	function GiveBack.Inputs.Down.P(AllInputsSpace)
		io.write(AllWindowRenders.Space.FramesPerSecond, " FramesPerSecond\n")
	end
	function GiveBack.Inputs.Down.Backspace(AllInputsSpace)
		AllInputsSpace.Text = AllInputsSpace.Text:sub(1, -2)
		io.write(AllInputsSpace.Text, "\n")
	end
	return GiveBack
end
