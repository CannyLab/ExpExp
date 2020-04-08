import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np
import ast
import re
import glob
import tqdm

text_files = glob.glob('data/*Final_NG.txt')
print(text_files)
# txt_file = '1Cyrus_Final_GO.txt'

total_counts = np.zeros([15, 15], dtype=np.float32)


def load_maze(maze_file):
    commands = []
    start = None
    goal = None
    with open(maze_file, 'r') as in_f:
        for line in in_f:
            if line.strip():
                if re.match('maze:setEntityCell\([\d]*,.[\d]*.*\)', line.strip()):
                    commands.append(line.strip().split('Cell')[1])
                if re.match('maze:setEntityCell\([\d]*,.[\d]*.*P.*\)', line.strip()):
                    start = line.strip().split('Cell')[1]
                if re.match('maze:setEntityCell\([\d]*,.[\d]*.*G.*\)', line.strip()):
                    goal = line.strip().split('Cell')[1]

    maze_outline = np.ones([15, 15])

    # Set the maze outline
    for c in commands:
        tup = ast.literal_eval(c)
        maze_outline[tup[0]-1, tup[1]-1] = 0 if tup[2] == ' ' else 1

    # Find the goal and start
    if start:
        tup = ast.literal_eval(start)
        maze_outline[tup[0]-1, tup[1]-1] = 4
    if goal:
        tup = ast.literal_eval(goal)
        maze_outline[tup[0]-1, tup[1]-1] = 2
    return maze_outline


### DO the actuall plotting

for idx, txt_file in enumerate(tqdm.tqdm(text_files)):

    maze_file = 'maps/naren_manual_eliza_{}.lua'.format(txt_file[-6:-4])
    run_name = txt_file.replace('.txt', '')

    samples = []
    with open(txt_file, 'r') as in_f:
        for line in in_f:
            x = float(line.strip().split(',')[0])
            y = 1500 - float(line.strip().split(',')[1])
            if int(x) == 750 and int(y) == 1450:
                continue # Fix small bug where resetting would mess with the figures
            samples.append((x, y))

    data = np.array(samples)

    # Load the maze outline
    maze_outline = load_maze(maze_file)

    # Plotting

    # Plot the base maze
    cmaplist = [
            (1.0, 1.0, 1.0, 1.0),
            (0.0, 0.0, 0.0, 1.0),
            (0.0, 1.0, 0.0, 1.0),
            (1.0, 0.0, 0.0, 1.0),
            (0.0, 0.0, 1.0, 1.0),
        ]
    maze_cmap = mpl.colors.LinearSegmentedColormap.from_list(
        'Custom cmap', cmaplist, len(cmaplist))
    base_maze = np.kron(maze_outline, np.ones([100, 100]))
    plt.imshow(base_maze, cmap=maze_cmap)

    # Build and plot the heatmap
    counts = np.zeros([15, 15])
    for d in data:
        counts[int(d[1] // 100), int(d[0] // 100)] += 1
    hist_cmap = mpl.cm.get_cmap('Reds')
    hist_cmap.set_under([0, 0, 0, 0])
    plt.imshow(np.kron(counts, np.ones([100, 100])), vmin=0.01, cmap=hist_cmap, alpha=0.7)

    total_counts += (counts.astype(np.float32) / np.sum(counts))

    # Plot the trajectory
    trajectory = np.zeros([1500, 1500])
    for i, d in enumerate(data):
        for dx in range(-3, 3):
            for dy in range(-3, 3):
                trajectory[int(d[1]) + dx, int(d[0]) + dy] = i
    trajectory_cmap = mpl.cm.get_cmap('cool')
    trajectory_cmap.set_under([0, 0, 0, 0])
    plt.imshow(trajectory, cmap=trajectory_cmap, vmin=0.01, vmax=50000)

    # Set up some details for the final presentation
    cbar = plt.colorbar()
    cbar.set_label('Trajectory Steps Taken')
    plt.title(run_name)
    plt.axis('off')

    # plt.show()
    plt.savefig('figures/' + txt_file.replace('.txt', '.png'))
    plt.clf()

# Final plot drawing
maze_outline = load_maze('maps/naren_manual_eliza_NG.lua')
cmaplist = [
            (1.0, 1.0, 1.0, 1.0),
            (0.0, 0.0, 0.0, 1.0),
            (0.0, 1.0, 0.0, 1.0),
            (1.0, 0.0, 0.0, 1.0),
            (0.0, 0.0, 1.0, 1.0),
        ]
maze_cmap = mpl.colors.LinearSegmentedColormap.from_list(
    'Custom cmap', cmaplist, len(cmaplist))
base_maze = np.kron(maze_outline, np.ones([100, 100]))
plt.imshow(base_maze, cmap=maze_cmap)

plt.title('NG Exploration Heatmap')
plt.axis('off')

hist_cmap = mpl.cm.get_cmap('Reds')
hist_cmap.set_under([0, 0, 0, 0])
plt.imshow(np.kron(total_counts, np.ones([100, 100])), vmin=0.0001, cmap=hist_cmap, alpha=0.7)
cbar = plt.colorbar()
cbar.set_label('Percentage of trajectory spent in maze cell')
plt.savefig('figures/NG_Counts.png')
