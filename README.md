# Chicken
A basic model of pecking task for birds. 

## Python environment
To use the environment in Python programms you can install Python module `python_env/chicken.py` using `python_env/setup.py`.

Control of the environment is through `Chicken` class:

- `obs()` - returns a tuple: (image observation array, reward, terminal state flag)
- `act([phi float, m float])` - apply impulse with direction `phi` in radians and magnitude `m`
- `step()` - do one simulation step if run with `--sync=true` flag
- `reset(position=None)` - return agent to the initial position and zero velocity, if position is not specified, it uses initial position from config file

For more detailed API see the source code.

To run the environment through Python you need to compile an executable file of the environment through Godot editor. The executable has several useful flags:

- `--config=config_path` specify wich configuration you would like to run with
- `--host=ip_addr` and `--port=port` specify ip address and port of the environment that will be used for TCP connection between Python and Godot parts.  
- `--disable-render-loop` and `--no-window` are useful for a headless run.
- `--fixed-fps` breaks real-time synchronization of physics and render, useful for headless rendering.
- `--sync=true/false` if `true`, simulation is paused until the next frame is requested by Python environment.
- `--seed=seed` setup seed to reproduce simulations.

# Related work
Code realisation of interaction between Godot and Python parts of the environment is mostly inspired by [this](https://github.com/edbeeching/godot_rl_agents) repository. 
