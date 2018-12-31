# GossipSimulator
#Description
A simulation of large network of nodes connected in different topologies. Gossip Algorithm is used to pass a message to entire network or to calculate average of numbers.

# Working topologies and algorithms – Largest network
Line topology – Gossip 10000
Imperfect line topology – Gossip 10000
Random 2D topology – Gossip 5000
Torus topology – Gossip 5000
3D grid topology – Gossip 5000
Full network topology – Gossip 10000
Line topology – Pushsum 10000
Imperfect line topology – Pushsum 10000
Random 2D topology – Pushsum 5000
Torus topology – Pushsum 5000
3D grid topology – Pushsum 1000
Full network topology – Pushsum 5000

# Project Execution –
mix run --no-halt proj2.exs 10000 imline gossip

# usage: 
mix run --no-halt proj2.exs <n> <topology> <algorithm>
Where n is number of nodes.
Topology can be full|3D|2D|rand2D|torus|line|imline.
Algorithm can be gossip|push-sum.

