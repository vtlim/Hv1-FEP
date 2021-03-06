#!/usr/bin/python

import os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl


# ============ Parameters ===================

#pose = '17041_19'
#pose = '17041_13'
pose = '15183_04'
plotrmsd = False

if plotrmsd:
    filename = "rmsd_withStart-redefined.dat"
    delimiter = " \t "
#    numCols = 2 # first n data columns
    cols = [1,3] # first and 3 data columns
    xlabel = "time (ns)"
    ylabel = "RMSD ($\AA$)"
    plttitle = "RMSD: 2GBI in Hv1, pose %s" % (pose)
    leglabel = ["TM backbone","2GBI"]
    figname = "plot_rmsd_%s-redefined.png" % pose

if not plotrmsd:
    filename = "hv1+gbi_contacts.dat"
    delimiter = "  "
    numCols = 5
    xlabel = "time (ns)"
    ylabel = "Distance ($\AA$)"
    plttitle = "Hv1 Contacts with 2GBI, pose %s" % pose
    leglabel = ["F150-benzo","R211-guan","D112-imid","S181-imid","R211-imid"]
    figname = "plot_contacts_%s.png" % pose

# ===========================================



os.chdir('/pub/limvt/hv1/02_configs/%s/analysis/' % (pose))

with open(filename) as f:
    data = f.read()
data = data.split('\n')[1:-1]

### Load data for x column.
x = [float(row.split(' ')[0]) for row in data]
# Convert the x-axis to ns (based on 2 fs step)
x = 0.002*np.array(x)
x = x+5 # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

### Load data for y columns.
y_mat = []
try:
    for i in cols:
       y_mat.append([row.split(delimiter)[i] for row in data])
except NameError:
    for i in range(1,numCols+1):
       y_mat.append([row.split(delimiter)[i] for row in data])
y_mat = np.array(y_mat)

### Initialize figure.
fig = plt.figure()
ax1 = fig.add_subplot(111)

### Label the figure.
ax1.set_title(plttitle,fontsize=20) 
ax1.set_xlabel(xlabel,fontsize=18)
ax1.set_ylabel(ylabel,fontsize=18)
for xtick in ax1.get_xticklabels():
    xtick.set_fontsize(16)
for ytick in ax1.get_yticklabels():
    ytick.set_fontsize(16)

### Set plot limits.
#axes = plt.gca()
#axes.set_ylim([0,6])

### Color the rainbow.
n, _ = y_mat.shape
colors = mpl.cm.rainbow(np.linspace(0, 1, n))
#colors = mpl.cm.rainbow(np.linspace(0, 0.4, n))

### Plot the data.
for color, y in zip(colors, y_mat):
    ax1.plot(x, y, color=color)
leg = ax1.legend(leglabel,loc=2)

plt.savefig(figname)
plt.show()


