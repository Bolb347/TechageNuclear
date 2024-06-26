An addon for the Techage Modpack in Minetest, adding nuclear fission
Techage Modpack found at https://github.com/joe7575/techage/tree/master


Tutorial:
Use the grinder to crush sieved basalt gravel into Uranium 238
Enrich the uranium into Uranium 235

Create fuel rods from that Uranium


Craft components for a nuclear reactor
- Controller - turning on the reactor and placing the fuel rods
- Reactor Casing - creating the shell
- Water Inlet - adding water the the reactor
- Steam Outlet - removing steam from the reactor
- Cells - consumes rods to create heat - Creates 8 h
- Coolers - cool the reactor to create steam - Cools 3 h


Craft components for a turbine
- Controller - turning on the turbine
- Turbine Casing - creating the shell
- Steam Inlet - adding steam the the turbine
- Water Outlet - removing cooled water from the reactor
- Turbines - create the electricity from the steam
- Cable Block - removing power from the system (will delete power if not given space to store it)

Construct a Basic Setup
Reactor:
- Make a 4x5 plate of reactor casing
- Line the edges 2 nodes high, making a 4x5x2 border, using reactor casings
- Fill the inside of the reactor with 3 fuel cells and 8 coolers
- Fill in the top, a 4x5, with reactor casing
- Remove 3 reactor casings, replacing them with 1 controller, 1 water inlet, and 1 steam outlet
Turbine:
- Make a 3x3 plate of turbine casing
- Line the edges, making a 3x3 border, using turbine casing
- Fill the inside of the turbine using turbines
- Fill the top, a 3x3, with turbine casing
- Remove 4 turbine casing, replacing them with 1 controller, 1 cable casing, 1 steam inlet, and 1 water outlet

NOTICE: BOTH THE REACTOR AND TURBINE SHOULD HAVE A SOLID SHELL AROUND THEM

Setup:
1. Fill the reactor controller with fuel rods
2. Fill the water inlet in the reactor with water
3. Turn the reactor on
4. Once turned on, it should produce steam and add it to the steam outlet
5. Connect the output of the reactor to the input of the turbine, to pipe the steam produced by the reactor into the turbine
6. Connect the cable casing in the turbine to a power network (it will dump all of the energy produced into the network)
7. Connect the output of the turbine to the input of the reactor, to pipe the water produced by the turbine into the reactor
8. Fill the system with some starting water; Once it has some water, the reactor doesn't lose any water nor gain any
9. You are done! You have a completed reactor setup
10. After this, I would recomend you to expand the size of both the reactor and steam turbine; They can be a maximum of 10x10x10! Make sure to keep your reactors as optimal as possible, using a 3:8 cell:cooler ratio, as suboptimal designs will get diminishing returns.
11. With a larger reactor, you produce more steam, but also consume more fuel rods; I would recomend automating the production of fuel rods, and the reprocessing of nuclear waste

NOTE: Reactors which are more optimal will subsequently produce more steam than a less optimal design.

After you have accumulated some nuclear waste, craft a reprocessor. This will allow you to recycle your waste, unlocking a new isotope, Plutonium 239. Use this plutonium to craft some RTGs, which are small and portable power sources.

TODO:
Add radiation damage
