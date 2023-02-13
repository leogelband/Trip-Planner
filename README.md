A Trip Planner tool coded in DSSL2 for my CS 214 class

Here is an overview of the Abstract Data Types and Algorithms I used in this project, followed by their role, which data structure is used, and my reasoning for them:

 ●   Dictionary (posn_id) 
 ○   Uses the position of a node as the key and gives it an identification number as 
 the value. It is paired with an array whose indices are the identification numbers 
 and whose values are the corresponding positions to have bi-directionality. 
 ○   Hash table 
 ○   A hash table can hold many elements while keeping operations like lookup 
 efficient even for very large graphs, making the program work faster. 
 ●   WUGraph (graph) 
 ○   Pretty self-explanatory – sets the points and roads as vertices and edges, 
 respectively. This is the underlying backbone of the project. 
 ○   Adjacency matrix-based weighted, undirected graph 
 ○   An adjacency matrix graph is preferable over an adjacency list graph especially 
 when graphs are not sparse, as it makes operations like adding/getting edges 
 have better time complexity than an adjacency list graph would. Roads can be 
 accessed from either end, so it is undirected, and roads have a certain length, so 
 we can use the weights in the edges to represent that length. 
 ●   Dictionary (poisnodupes) 
 ○   Creates a dictionary with the position of all POIs without duplicates. This helps 
 me to keep track of which positions have already been inserted into the linked list 
 without having to loop through the entire list and to avoid duplicates in locate_all. 
 ○   Hash table 
 ○   A hash table can hold many elements while keeping operations like lookup 
 efficient even for very large graphs, so it's useful when viewing whether a given 
 POI has already been inserted into the dictionary. 
 ●   Dictionary (nametoposn) 
 ○   It maps a POI's name (key) to its corresponding position (value). 
 ○   Hash table 
 ○   Again, a hash table can hold many elements while also making operations like 
 lookup more efficient. 
 ●   Sequence (posntopoi) 
 ○   This array has sequences in each index that holds struct for the POI's position, 
 category, and name grouped by position. These are useful for find_nearby to loop 
 through each POI and get its information. 
 ○   Linked list 
 ○   I chose a linked list because I don't know exactly how many POIs there are in 
 each position, so this seemed like a more efficient way to avoid storing empty 
 data points that I can later cycle through rather than creating several arrays that 
 are larger than needed. 
 ●   Priority Queue (todo in Dijkstra's) 
 ○   This priority queue is useful because it will order edges such that we can know 
 which node should be relaxed next by edge weight according to Dijkstra's 
 algorithm. 
 ○   Binary heap 
 ○   A binary heap is more efficient than list-based priority queues, so it can help to 
 find the next edge to be relaxed in a more productive manner than those. 
 Algorithms  : 
 ●   What role does it play in solving the problem? 
 ●   Why did you pick that algorithm over other choices? 
 Dijkstra's algorithm (dijkstra): 
 ●   Dijkstra's algorithm is necessary because it helps find the shortest path between two 
 nodes in a graph using a priority queue to relax nodes in an efficient way. I used it in 
 plan_route and find_nearby to help make these work efficiently. 
 ●   This algorithm is more efficient than the Bellman-Ford approach because it relaxes 
 nodes in a more clever way. Since we are not working with negative distances and 
 therefore have no negative cycles, it will be more productive to use Dijkstra's than 
 Bellman-Ford. 
 Heap_sort in find_nearby: 
 ●   Finds and returns the nodes on the graph ordered by distance, so it helps find the 
 shortest path in an efficient (O(nlog n)) way. 
 ●   Heap_sort has a pretty favorable time complexity which makes it efficient even in the 
 worst case.
