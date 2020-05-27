-*-Mode: markdown;-*-
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
miniVite-x
=============================================================================

* https://gitlab.pnnl.gov/perf-lab-hub/miniVite-x

miniVite-x consists of three different variants of miniVite
(https://github.com/Exa-Graph/miniVite), a mini-app for Community
Detection. The three variants vary the implementations of key hash
tables used in the algorithm.

miniVite-x was developed for the following paper:

  Ozgur O. Kilic, Nathan R. Tallent, and Ryan D. Friese, "Rapid memory footprint access diagnostics," in Proc. of the 2020 IEEE Intl. Symp. on Performance Analysis of Systems and Software, IEEE Computer Society, May 2020.

Contacts:
- Nathan R. Tallent <tallent@pnnl.gov>
- Ozgur Kilic <ozgur.kilic@pnnl.gov>


-----------------------------------------------------------------------------
Details:
=============================================================================

The versions vary two hash tables. The most important one is CLMap,
the source of a performance hotspot used in the function
distBuildLocalMapCounter() (BLMC). BLMC is a loop that inspects the
neighboring communities for each vertex. BLMC, which is called for
each (local) vertex, loops over all edges for the vertex and
calculates the (local) contribution to each community's
modularity. The loop uses a C++ `std::unordered_map` to store each
community's contribution to modularity.

The C++ `std::unordered_map` is implemented as an open hash table,
i.e., an array of keys, each containing a linked list for
items. Traversing the hash table is creates costly memory references
due to traversing linked lists.

We create variants using hash tables based on closed hashing, which
stores both keys and items in a single contiguous array.  Closed
hashing can results in memory accesses with much better locality.
Even though it may results in more loads, the over all access times
can be far less, resulting in significant performance improvements.

In particular, we swapped the default CLMap implementation with TSL
hopscotch, a closed hash table implementation of hopscotch hashing
[1]. We experimented with both TSL hopscotch and TSL robin:
  - tsl::hopscotch: https://github.com/Tessil/hopscotch-map
  - tsl::robin:     https://github.com/Tessil/robin-map
  - Comments: https://tessil.github.io/2016/08/29/benchmark-hopscotch-map.html
Results are given in the ISPASS paper above.

The variants are as follows.

* Version 1 (v1). CLMap = `stl::unordered_map`.

  This is the original code with new hash map types to facilitate type
  parameteriazation. The orginal code is based on:

  ```sh
    git clone https://github.com/Exa-Graph/miniVite
    git checkout fb73ce99b355a70ab7951990b47224eae208acd4
  ```

* Version 2 (v2):
  - CLMap = `tsl::hopscotch` (default initial size).
  - RemoteComm = `tsl::robin`
  
  This version has better performance than the orginal, but
  can generates *many* unnecessary loads due to many map resizes.

* Version 3 (v3): Begin with v2, but CLMap is created with the initial
  size set to the degree of the vertex, to avoid resizing.

* Version 4 (v4): CLMap is created once, and resized for each
  vertex. Not shown.


[1] M. Herlihy, N. Shavit, and M. Tzafrir, "Hopscotch hashing," in Distributed Computing, G. Taubenfeld, Ed. Berlin, Heidelberg: Springer Berlin Heidelberg, 2008, pp. 350--364.
