import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import numpy as np
import pandas as pd

img = mpimg.imread(r"C:\Users\sebas\Pictures\Screenshots\Schermafbeelding 2025-12-15 141430.png")
df = pd.read_csv(r"C:\Users\sebas\Downloads\death_events_rows.csv")
level_df = df[df['death_level'] == 'Ravine_1']

x = level_df['death_x'].values
y = level_df['death_y'].values
x_min, x_max = -3056, 7344
y_min, y_max = 272, -4064

fig, ax = plt.subplots()

ax.imshow(img, extent=[x_min, x_max, y_min, y_max], aspect= 'auto')

ax.set_xlim(x_min, x_max)
ax.set_ylim(y_min, y_max)

ax.scatter(x, y, color='green', s=5)

plt.show()