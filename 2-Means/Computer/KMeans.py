import numpy as maths
import matplotlib.pyplot as graph

# No. of features = m.
# No. of examples = n.

def loadData():
	dataset =[[]] 				# Weirdly, there is a blank item at the first index of the list.
	f = open("CustomData.dat", "r")
	# Source: Customized datasets from http://www.generatedata.com
	skip = f.readline()	#Skips the column headers
	for x in f:
		features =list(map(int, x.split()))
		dataset.append(features)
	dataset.pop(0)			# Get rid of the first blank element.
	f.close()
	return(dataset)

def init_means(k, m, n, data):
	cmin = [] * m
	cmax = [] * m
	for i in range (0, m):
		mn = mx = data[0][i]
		for j in range(1, n):
			if(data[j][i] > mx):
				mx = data[j][i]
			if(data[j][i] < mn):
				mn = data[j][i]
		cmin.append(mn)
		cmax.append(mx)
		
	means = [[] * m]
	for i in range(0, k):
		point = []
		for j in range(0, m):
			point.append(maths.random.uniform(cmin[j], cmax[j]))
		means.append(point)
	means.pop(0)				# Get rid of the first blank element.
	return(means)
		
def form_cluster(data, k, means, m, n):
	buckets = [[0] * m for cols in range(k)]
	b_len = [0] * k;
	for i in data:		# Create buckets
		min_d = 99999999
		min_i = 0	
		for j in range (0, k):
			d = getEuclidianDist(i, means[j], m)
			if(d < min_d):
				min_d = d
				min_i = j
		for feat in range(0, m):
			buckets[min_i][feat] += i[feat]
		b_len[min_i] += 1

	for i in range(0, k):
		for j in range(0, m):
			buckets[i][j] /= b_len[i]
	return(buckets)

def getEuclidianDist(A, B, m):	# A & B are points.
	d = 0
	for i in range(0,m):
		d += (A[i] - B[i])**2
	return(maths.sqrt(d))
	

#main
# Load Data.
dump = input("\t\tK-MEANS CLUSTERING (VALIDATION USING PYTHON)\n\nPress Enter to load the data and begin clustering.\n")
dataset = loadData()
m = len(dataset[0])
n = len(dataset)
k = 2					# Set number of clusters here.
new_means = [0] * k

# Initialize clusters.
means = init_means(k, m, n, dataset)

# Initialize the graph.
clusters = graph.figure()

x = [p[0] for p in dataset]
y = [p[1] for p in dataset]
graph.plot(x, y, 'bx')

# Perform clustering.
correction = 100
while(correction > 0.01):
	new_means = form_cluster(dataset, k, means, m, n)
	correction = 0
	for i in range(k):
		for j in range(m):
			correction += (new_means[i][j] - means [i][j]) ** 2
	means = new_means
	#print("Correction: " + str(correction))

print("Converged centroids:")
for i in means:
	print(i)
print("\n")

x = [p[0] for p in means]
y = [p[1] for p in means]
graph.plot(x, y, 'ro')

f = open("centroids.dat", 'r')
means = [list(map(int, line.split())) for line in f]
f.close()
print("Centroids identified by the FPGA:")
for i in means:
	print(i)
print("\n")
x = [p[0] for p in means]
y = [p[1] for p in means]
graph.plot(x, y, 'yo')

# Label the graph here:
clusters.suptitle('K-Means clustering', fontsize=14, fontweight='bold')
graph.xlabel('X')
graph.ylabel('Y')
graph.show()
