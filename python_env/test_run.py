import numpy as np
import matplotlib.pyplot as plt
import yaml
import os
import sys
from chicken import Chicken


if __name__ == '__main__':
    with open('config.yaml', 'r') as file:
        config = yaml.load(file, yaml.Loader)

    exe_path = os.environ.get('CHICKEN_EXE', None)
    if exe_path is not None:
        config['exe_path'] = exe_path

    if len(sys.argv) > 1:
        config['config_path'] = sys.argv[1]

    env = Chicken(
        **config
    )

    while True:
        env.reset()
        for i in range(10):
            env.step()
            im, reward, is_terminal = env.obs()
            print(reward, is_terminal)
            plt.imshow(im)
            plt.show()
            action = np.random.random(size=3) > 0.5
            shift = action[:2]*1.0
            action = float(shift[0]), float(shift[1]), bool(action[-1])
            print(action)
            env.act(action)
