#lang dssl2

# Final project: Trip Planner

import cons
import sbox_hash
import 'project-lib/binheap.rkt'
import 'project-lib/dictionaries.rkt'
import 'project-lib/graph.rkt'
import 'project-lib/stack-queue.rkt'

let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]
### Basic Types ###

#  - Latitudes and longitudes are numbers:
let Lat?  = num?
let Lon?  = num?

#  - Point-of-interest categories and names are strings:
let Cat?  = str?
let Name? = str?

### Raw Entity Types ###

#  - Raw positions are 2-element vectors with a latitude and a longitude
let RawPos? = TupC[Lat?, Lon?]

#  - Raw road segments are 4-element vectors with the latitude and
#    longitude of their first endpoint, then the latitude and longitude
#    of their second endpoint
let RawSeg? = TupC[Lat?, Lon?, Lat?, Lon?]

#  - Raw points-of-interest are 4-element vectors with a latitude, a
#    longitude, a point-of-interest category, and a name
let RawPOI? = TupC[Lat?, Lon?, Cat?, Name?]

### Contract Helpers ###

# ListC[T] is a list of `T`s (linear time):
let ListC = Cons.ListC
# List of unspecified element type (constant time):
let List? = Cons.list?


interface TRIP_PLANNER:

    # Returns the positions of all the points-of-interest that belong to
    # the given category.
    def locate_all(
            self,
            dst_cat:  Cat?           # point-of-interest category
        )   ->        ListC[RawPos?] # positions of the POIs

    # Returns the shortest route, if any, from the given source position
    # to the point-of-interest with the given name.
    def plan_route(
            self,
            src_lat:  Lat?,          # starting latitude
            src_lon:  Lon?,          # starting longitude
            dst_name: Name?          # name of goal
        )   ->        ListC[RawPos?] # path to goal

    # Finds no more than `n` points-of-interest of the given category
    # nearest to the source position.
    def find_nearby(
            self,
            src_lat:  Lat?,          # starting latitude
            src_lon:  Lon?,          # starting longitude
            dst_cat:  Cat?,          # point-of-interest category
            n:        nat?           # maximum number of results
        )   ->        ListC[RawPOI?] # list of nearby POIs


struct posn:
    let lat
    let long

struct road_seg:
    let point1_lat
    let point1_long
    let point2_lat
    let point2_long
    let len
    
## length will be = sqrt(point1.lat^2 + point2.lat^2)
    
struct poi:
    let position
    let category #string
    let name #string

struct vd:
    let vertex
    let distance      
            
def dist(px1, py1, px2, py2):
    return ((px2-px1)**2+(py2-py1)**2).sqrt()    

class TripPlanner (TRIP_PLANNER):
    let roads 
    let pois
    let graph 
    let allcategories
    let poisnodupes
    let posn_id
    let id_posn
    let nametoposn
    let posntopoi
    
  ####################################### dunno 
   
    def __init__(self, roads, pois):
        self.roads = roads
        self.pois = pois
        
        self.posn_id = HashTable(len(roads)*2, make_sbox_hash())
        self.id_posn = vec(len(roads)*2)

        let q = 0
        for road in roads:
            let posn1 = posn(road[0], road[1])
            let posn2 = posn(road[2], road[3])
            
            if not self.posn_id.mem?(posn1):
                self.posn_id.put(posn1, q)
                self.id_posn[self.posn_id.get(posn1)] = posn1
                q = q + 1
            
            if not self.posn_id.mem?(posn2):
                self.posn_id.put(posn2, q)
                self.id_posn[self.posn_id.get(posn2)] = posn2
                q = q + 1    
                    
        let n_points = self.posn_id.len()
                
        self.graph = WuGraph(n_points)
 
        for road in roads:                  #better to create new for loop and add linear time complexity to be able to create graph and vec with lower capacity to improve dijkstra time complexity
            let posn1 = posn(road[0], road[1])
            let posn2 = posn(road[2], road[3])
            let weight = dist(road[0], road[1], road[2], road[3])
            self.graph.set_edge(self.posn_id.get(posn1), self.posn_id.get(posn2), weight)

#            if not allpositions.mem?(poiposn):
#                allpositions.put(poiposn, q)
#                q = q + 1
               

        

# let RawPOI? = TupC[Lat?, Lon?, Cat?, Name?]
        
        self.allcategories = vec(n_points)
        let i = 0
             
        self.poisnodupes = HashTable(len(self.pois), make_sbox_hash())
        
        self.nametoposn = HashTable(len(self.pois), make_sbox_hash())
        self.posntopoi = vec(n_points)

        for point in self.pois:
            let pointposition = posn(point[0], point[1])
            self.nametoposn.put(point[3], pointposition)

            self.posntopoi[self.posn_id.get(pointposition)] = cons(poi(pointposition, point[2], point[3]), self.posntopoi[self.posn_id.get(pointposition)])
    
#################################################################3
    def locate_all(self, dst_cat:  Cat?):   
        let allpoints = None
        for point in self.pois:
            let pointposition = [point[0], point[1]]
            if point[2] == dst_cat and not self.poisnodupes.mem?(pointposition): 
                self.poisnodupes.put(pointposition, 0)
                allpoints = cons(pointposition, allpoints)
#            if point[2] == dst_cat: # and not allpoints.mem?(pointposition):        
        return allpoints

 ##################################################################       
    def dijkstra(self, startnode):
        let todo = BinHeap(self.posn_id.len()*2, lambda x, y: x.distance < y.distance)
        
        let done = vec(self.posn_id.len()) #lugares q ja foi
        let dist = vec(self.posn_id.len()) #distances
        let pred = vec(self.posn_id.len()) #predecessors
        
        todo.insert(vd(startnode, 0))
        
        for i in range(self.graph.len()):
            if i != startnode:
                dist[i] = inf
            else:
                dist[i] = 0
            
        while todo.len() != 0:
            let min = todo.find_min()
                
            todo.remove_min()
           # if min.distance + todo.find_min().distance <  
            if done[min.vertex] is None:
                done[min.vertex] = 1
                let adj = self.graph.get_adjacent(min.vertex)

                while adj is not None:

                    let weight = self.graph.get_edge(min.vertex, adj.data)
                    if dist[min.vertex] + weight < dist[adj.data]:
                        dist[adj.data] = dist[min.vertex] + weight
                        pred[adj.data] = min.vertex
                        todo.insert(vd(adj.data, dist[adj.data]))
                    adj = adj.next


        return [pred, dist]
   
 #################################################################3   
    def plan_route(self, lat:  Lat?, lon:  Lon?, name: Name?):          # name of goal
        if not self.nametoposn.mem?(name) or not self.posn_id.mem?(posn(lat, lon)):
            return None
        
        let id = self.posn_id.get(posn(lat, lon))
        let end = self.posn_id.get(self.nametoposn.get(name))
        
        let predecessors = self.dijkstra(id)[0]
        let endpred = predecessors[end]
        let path = cons([self.id_posn[end].lat, self.id_posn[end].long], None)
        
        if endpred is None and id != end:
            return None
        else:
            while endpred is not None:
                path = cons([self.id_posn[endpred].lat, self.id_posn[endpred].long], path)
                endpred = predecessors[endpred]
        
        return path
 ####################################################################       
    def find_nearby(self, lat, lon, cat, n):
        let start = self.posn_id.get(posn(lat, lon))
        let dist = self.dijkstra(start)[1]

        let poilist = None

        #let all = self.locate_all(cat) # linked list w vectors for posn

        let vecs = vec(dist.len())
        for j in range(vecs.len()):
            vecs[j] = vd(j, dist[j])
        
        heap_sort(vecs, lambda x, y: x.distance < y.distance)
        let i = 1
        for vec in vecs:

            if self.posntopoi[vec.vertex] is not None and vec.distance != inf:
                let idtopoi = self.posntopoi[vec.vertex]
                while idtopoi is not None:
                    if cat == idtopoi.data.category:
                        let wawa = [idtopoi.data.position.lat, idtopoi.data.position.long, cat, idtopoi.data.name]
                        poilist = cons(wawa, poilist)
                        i = i + 1
                    idtopoi = idtopoi.next
                    if i > n:
                        return poilist

        return poilist
#            while idtoposn is not None:
 #               if idtoposn.category == cat:
  #                  i = i + 1 
   #                 let point = idtoposn
    #                poilist = cons(wawa, poilist)
     #               pass
                    
        #if all is None:
         #   return []
            #
    ##  else:
#            for j in range(vecs.len()):
 #               let posin = posn(all.data[0], all.data[1])
  #              let poiid = self.posn_id.get(posin)
   #             let length = dist(posin.lat, posin.long, lat, lon)
    #            vecs[poiid] = vd(poiid, length)
     #           if vecs[j] == None:
      #              vecs[j] = vd(inf, inf)
            
#            heap_sort(vecs, lambda x, y: x.distance < y.distance)

    
#            let i = 1
#            while all is not None:
 #               let posntoid = self.posn_id.get(posn(all.data[0], all.data[1]))
  #              #let idtoposn = self.id_posn[vecs[i].vertex]
   #             let idtoposn = self.id_posn[posntoid]
    #            let wawa = self.posntoname.get(idtoposn)
     #           let blabla = [idtoposn.lat, idtoposn.long, cat, wawa]
      #          poilist = cons(blabla, poilist)
       #         i = i + 1
        #        all = all.next
        
       # return poilist
#         cons([0,1, "food", "Pelmeni"], None)
        
      ###########################################3  
 #       let POIs = HashTable(n_points, make_sbox_hash())
#
   
    
    #### ^^^ YOUR CODE HERE


def my_first_example():
    return TripPlanner([[0,0, 0,1], [0,0, 1,0]],
                       [[0,0, "bar", "The Empty Bottle"],
                        [0,1, "food", "Pelmeni"]])

test 'My first locate_all test':
    assert my_first_example().locate_all("food") == \
        cons([0,1], None)

test 'My first plan_route test':
   assert my_first_example().plan_route(0, 0, "Pelmeni") == \
       cons([0,0], cons([0,1], None))

test 'My first find_nearby test':
    assert my_first_example().find_nearby(0, 0, "food", 1) == \
        cons([0,1, "food", "Pelmeni"], None)

def example_from_handout():
    return TripPlanner([[0,0, 0,1], [0,1, 0,2], [0,2,1,2], [1,0,1,1], [1,1,1,2], [0,0,1,0], [0,1,1,1], [1,2,1,3], [1,3,-0.2,3.3]],
                       [[0,0, "food", "Sandwiches"],
                       [0,1, "food", "Pasta"],
                       [1,1, "bank", "Local Credit Union"],
                       [1,3, "bar", "Bar None"],
                       [1,3, "bar", "H Bar"],
                       [-0.2,3.3, "food", "Burritos"]])