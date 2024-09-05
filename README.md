# Chicken
A basic model of pecking task for birds written in Godot 4 with Python environment for RL algorithms use. 

The agent representing a bird is able to move in 2D space and peck. Agent observes a square surface covered with objects of different shapes, sizes and colors.
Eatable objects are destroyed when pecked. 

![example.png](assets/example.png)

## Requirements
**Godot 4** (4.2.1stable tested) and **Python 3.9+** to control the environment from code. 

## Configuration
See `configs` folder for examples.

- `field_size`: specify the size of grid used to scatter objects. Total number of objects equals to `field_size` squared, since the grid is square.
- `weights`: list of relative weights of each set during sampling. Equal numbers mean that sets are sampled uniformly.
- `sets`: list of sets, each set has the following parameters: `shape`, `size`, `rotation`, `color`, `roughness`, `edible`.
  Each parameter is defined as random variable in the form of lists `['categorical', values, probs]` or `['uniform', min, max]`.
  - `shape`: supports only `categorical` distribution, values should be names of `.obj` files without extension from `assets/shapes` folder. So that to add a shape, just add new `.obj` file to the folder.  
  - `size`: a float value, can be both `categorical` and `uniform`. Uniformly scales the original shape.
  - `rotation`: rotate shape along vertical axis, measured in degrees. It can be both `categorical` and `uniform`.
  - `color`: values should be `RGB` tuples, support only `categorical` distribution.
  - `roughness`: a float value in range `[0, 1]`. `0` means completely smooth shiny object and `1` is the opposite. It can be both `categorical` and `uniform`.
  - `edible`: is interpreted as a boolean value, specifying whether the object edible or not. Edible objects give `+1` positive reward and disappear after pecked.


## Control
Running executable in standalone regime without python environment is mainly for testing purposes.
- move agent: `WASD` or arrows
- peck: `SPACE`
- change camera view `C`
- toggle first-person camera preview `F`

## Python environment
To use the environment in Python 3.9+ programs:
1. install environment into your Python environment using `python_env/setup.py` and requirements from `python_env/requirements.txt`.
2. Open the project in Godot editor and export it to executable file.
3. Specify path to your executable file in `python_env/config.yaml` or though the `CHICKEN_EXE` variable. 
4. Test the environment by running `python python_env/test_run.py`.

Control of the environment is through `Chicken` class:

- `obs()` - returns a tuple: (image observation array, reward, terminal state flag)
- `act([move_x: float, move_y: float, peck: bool])` - move agent in 2D space and peck
- `step()` - do one simulation step if run with `sync: true`.
- `reset(position=None)` - return agent to the initial position, position can be a list `[x float, y float]` or `None`

# Related work
Code realisation of interaction between Godot and Python parts of the environment is mostly inspired by [this](https://github.com/edbeeching/godot_rl_agents) repository. 
