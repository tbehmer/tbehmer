Background:
-----------

When studying state interaction, researchers often want to account for spatial effects. A crisis in one state, for instance, is more likely to affect a neighboring state than merely a state in the same hemisphere or continent. Similarly, if we believe that any benefits given to a state also help a neighboring state via spillovers, then not accounting for the contiguity can undermine our assumption of independence across observations. Spatial effects are complicated by the fact that new states emerge over time by gaining independence, or the collapse of a larger empire - that is, any useful contiguity matrix, by necessity must also have a time-series component.

In this particular case, I wanted to calculate how much foreign aid a given donor provides globally, how much the donor gives to all countries except for the target country, and how much aid is given to the world except for the target country and its neighbors. With this in mind, I set out to create such a contiguity matrix.

Note: The original data on membership in the system of states is from the 2016 Correlates of War dataset. State contiguity is drawn from the directed dyad dataset on contiguity (version 3.2.0) also from Correlates of War. Aiddata.org is a wonderful resource for data on foreign aid, but for the purposes of this coding example, I merely simulated foreign aid flows between dyads rather than using real data.


How to use this file:
---------------------
This zipped folder contains four files. Aside from this readme, it contains the Stata do-file which compiles the contiguity matrix dataset. States2016.csv is a file containing state membership (from COW), and contdird_cow.dta contains the directed dyad contiguity data (also from COW). In order for the matrix file to compile, please open the do-file in Stata, and adjust the path at the top of do-file to the directory where you saved the unzipped files. Running said file will take awhile, and the output dataset will require approximately 500MB of hard drive space.
