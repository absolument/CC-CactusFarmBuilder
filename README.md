# CC-CactusFarmBuilder
Computercraft, turtle building a cactus farm

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

CC:Tweaked 1.83.1 ( https://github.com/SquidDev-CC/CC-Tweaked )

### Installing

Pastebin : https://pastebin.com/2SPDSxPt

```
pastebin get 2SPDSxPt build.lua
```

## Design

Based on a 3x3 tower for passive farming. When cactus grow up items will pop and fall on the floor. Build a pool below with water streams to harvest products.
![Cactus farm stages](https://raw.githubusercontent.com/absolument/CC-CactusFarmBuilder/master/2019-07-16_13.54.35.png)
![Cactus farm base](https://raw.githubusercontent.com/absolument/CC-CactusFarmBuilder/master/2019-07-16_15.24.26.png)

## Usage

Place your turtle on the floor (Full of fuel as far as possible), facing then center of cactus tower farm, at 3 blocks of distance.
Build the first stage of the cactus farm tower.
Then run the program, provide any materials. For one stage, at least : 4 cactus, 4 sand, 4 cobblestone, 2 fences, 1 torch
On inventory events, the number of stages the turtle can build is updated.
Presse Enter to start building. Then turtle will walk to the center and go up to the next stage to build and start to work. When job is done, the turtle will return to start position.

## Custom

If you choose other start position, edit theses parts :

```
function ascent()
	output("Ascent phase")
	
	--take place in the center
	output("Align to center")
	for i=1,3 do -- <--EDIT
		turtle.forward()
	end
```

```
function descent()
	output("Descent")
	repeat
		local move = turtle.down()
	until not move
	output("Repositionning")
	for i=1,3 do -- <--EDIT
		turtle.back()
	end
end
```

## License

Feel free


