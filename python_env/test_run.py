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
    action = (1.5, 1.5, 0)
    env.act(action)
    env.step()
    mine_session_length = 500
    for j in range(mine_session_length):
        env.set_config(config['config_path'])
        for i in range(20):
            # first move to an item and get its image
            action = np.random.random(size=3) > 0.5
            shift = 7. * (action[:2] - 0.5) * np.random.binomial(n=1, p=0.5, size=action[:2].shape)
            action = float(shift[0]), float(shift[1]), False
            env.act(action)
            env.step()
            im, _, _, _ = env.obs()

            # then peck it
            env.act((0, 0, True))
            env.step()
            _, reward, _, info = env.obs()

            plt.imshow(im)
            plt.title(f"{reward=}, {info=}")
            plt.show()

