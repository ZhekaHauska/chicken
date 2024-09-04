import numpy as np

from chicken import Chicken
import matplotlib.pyplot as plt


if __name__ == '__main__':
    env = Chicken(
        exe_path='../Chicken.x86_64',
        config_path='../configs/default.json'
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
