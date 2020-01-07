# Methods {#sec:methods}

This section describes our sources of data and our data reduction methods.

## Data Sources

The study relied primarily on seven data sources:

-   **Ridesourcing trip records:** ridesourcing companies submit individual
    trip records to the City, including origin, destination, request and pick-up
    timestamps, ride duration, distance, type of service (wheelchair-accessible,
    Uber XL, etc.), ridesplitting trip segment ID, and trip status \- whether
    the trip was cancelled by either driver or passenger. Origin and
    destination locations are snapped to the nearest intersection in the City's
    street centreline dataset \cite{centrelinexsection}. Records from September 7, 2016 to September 30,
    2018, were made available. After March 30, 2017, request time and trip status were no longer available in
    trip records, and pick-up timestamps were truncated to
    the nearest hour. Aggregate records for late 2018 and
    2019 were also provided.

-   **Supplementary aggregate ridesourcing statistics:** by our request, a
    subset of ridesourcing companies provided additional information including
    the number of active drivers per hour for selected days, average fraction
    of VKT while in-service and while deadheading aggregated over all vehicles
    in March 2017 and September 2018, and additional aggregated wait time data
    after April 2017.

-   **Ridesourcing pick-up and drop-off data:** pick-up and drop-off counts at
    a $10\,\mathrm{m}$ resolution \- significantly more precise than the trip
    record OD data \- were acquired using SharedStreets \cite{sharedstreetsactivity} as a
    broker in partnership with ridesourcing companies. The data is aggregated
    by hour and spans a total of 9 weeks from January to September 2018.

-   **Historical travel speed data:** travel speed data from September 2016
    \- October 2018 was provided by HERE Technologies for all available
    street segments; data represents the mean speed along road segments for
    5-minute increments. Speed data from October 2017 \- March 2019 was also
    acquired from the City's system of Bluetooth sensors along downtown
    arterial streets. This data is also in 5-minute increments, for road
    segments that span between major intersections. The HERE data covers the
    entire city and is used to estimate historical street network travel times.

-   **2016 Transportation Tomorrow Survey (TTS):** the TTS is a regional
    household travel survey conducted by the University of Toronto in
    collaboration with local and provincial government agencies. The survey
    collects demographic, travel behavior and travel mode information. The
    most recent survey was in 2016.

-   **Ridesourcing travel behavior survey:** a survey was undertaken by UTTRI
    in May 2019 to collect information from a market research panel on their
    revealed and stated transportation mode preferences for commute and
    non-commute trips. The survey's authors discuss their work in
    \trbcite{loatrb}.

-   **Street-linked vehicle volumes:** the output of the 2016 KCOUNT model
    described in \trbcite{volumemodel} are Annual Average Daily Traffic (AADT)
    volumes mapped to the City's street centreline network. 

Trip records, pick-up/drop-off data and historical speed data were hosted on
a PostGIS geospatial object-relational database (running on PostgreSQL 9.6)
\citep{postgres, postgis}.

## Methodology for Processing Curb Activity

Pick-up/drop-off (PUDO) data was provided with SharedStreets reference IDs. The
city's bikelane network was map-matched to the SharedStreets network using
their street segment matching toolkit in order to aggregate activity by
bikelane segment \cite{sharedstreetshowtomatch}.

## Methodology for Estimating Vehicle Volumes on Streets {#sec:volumesonstreets}

As described in \trbcite{henao2018impact}, ridesourcing drivers cycle between
three phases when serving multiple trips over their work period:

<!--- Raphael: Should these definitions be moved earlier? --->
<!--- Charles: I tried moving this up to an earlier section, but feel it makes
it clunkier -->

1.  **Cruising** while waiting to be matched with a passenger;

2.  Driving **en-route** to a pick-up once matched; and

3.  Driving **in-service** of the passenger.

Cruising and driving en-route are both forms of *deadheading* (driving
without a passenger). At the beginning and end of the work period, the driver
may also "commute" \- deadhead from and to another location such as a residence
or place of work. All of these behaviours contribute to VKT on streets.

The ridesourcing trip records include the in-service VKT, but not deadheading
VKT, nor were vehicle IDs or disaggregated wait times available. In order to localize
in-service VKT to specific areas of Toronto, we modeled the likely paths
drivers took from origin to destination for in-service activity.  To estimate
time and VKT spent deadheading, we also linked the destinations of trips
with the origins of subsequent trips in such a way that best reproduces the
empirical distribution of passenger wait-times, and modeled the likely paths
drivers took to complete these connections.

Due to the computational demands of this process, it was used on data from two
days out of the study period: October 20, 2016 with 64,800 trips and September
13, 2018 with 140,900 trips, both of which are within $8\%$ of
the average daily number of trips in their respective months, and
thus are representative of typical days near the beginning and end of the study
period. As request data was only available before April 2017, October 20
was also used for testing, calibration and validation.

### Trip Routing for In-Service Activity {#sec:triprouting}

To estimate in-service trip trajectories, we routed each trip from origin to
destination using pgRouting \citep{pgrouting}, a PostGIS \citep{postgis}
implementation of Dijkstra's Shortest Path algorithm. Trips were routed through
a street network weighted using HERE travel speed data for the 5-minute period
in which trips started. Gaps in traffic data were filled in by using data
models provided by HERE for each street segment by time of week.

Our routing methodology was:

1.  **Generate a routing network:** for each five-minute bin, we
    joined historical traffic data for that time with models for that day of
    week, 15-minute period and link provided by HERE. Link IDs
    were duplicated for bidirectional streets and re-drawn in the direction
    of travel. Source and target nodes for each link were also corrected to the
    direction of travel. The network mostly accounts for access restrictions
    and differences in road elevation but does not account for turn
    restrictions at intersections. The city's centreline network, to which
    vehicle volumes are mapped, was map-matched to the HERE network used for
    routing using the SharedStreets \cite{sharedstreetshowtomatch} toolkit in
    order to ensure similar streets networks were used to calculate
    ridesourcing VKT as a proportion of total City VKT. 

2. **Prepare trip records for routing:**

   a.  **Trips within Toronto:** for each trip record, the nearest node
        was found in the routable HERE network. These were typically the
        exact same intersections.

   b.  **Trips to/from outside of Toronto:** for trip records where the origin
        or destination was outside the city but within the six nearest
        municipalities, the node was assigned to be a Toronto intersection on
        that municipality's border representative of a major arterial or
        highway. Trips from or to beyond the six nearest municipalities
        (representing $0.3\%$ of all trips) were excluded from routing.

   c. **Generate Shared Ride Segments:** Ridesplitting
        trips - where several trips with different origins and destinations are
        served simultaneously by one vehicle - were re-ordered 
        into segments representing stops the ridesourcing driver 
        would have made in chronological order.

   d. **Impute Timestamps:** Trip record timestamps after March 30, 2017 were
   shifted to the start of the hour (for example \texttt{2018-09-13 07:47:00}
   becomes \texttt {2018-09-13 07:00:00}). For these, we imputed more precise
   pick-up timestamps by randomly sampling from other pick-ups within a one
   kilometer radius for the same date and hour from trip records provided to us
   separately by a ridesourcing company. The drop-off timestamp was then
   calculated from the duration of the trip provided at a minute resolution.

3.  **Route trip records:** five-minute batches were sent to a many-many
    Dijkstra routing engine with the network for that time period in
    batches of 250 unique origins and their corresponding destinations
    (due to memory limitations). The routing engine returns the shortest path
    for each OD pair given traffic conditions at that time. 

4.  **Determine volumes on streets:** vehicle volumes over a period of time were
    calculated for each segment of the routing network by summing up the number
    of paths that include the segment during this period. The corresponding
    total VKT was determined by multiplying the vehicle volume by the segment
    length. Neighbourhood ridesourcing VKT was then factored by the ratio of
    aggregate routed distance and the network distance of reported trips for
    the entire city.

\noindent Our code for routing trips is available at
[https://github.com/CityofToronto/bdit_triprouter](https://github.com/CityofToronto/bdit_triprouter).

### Trip Linking for Deadheading {#sec:triplinking}

There is a paucity of information in the trip records concerning any of the
phases of deadheading -- commuting, cruising or en-route driving.

Without vehicle trajectories, predicting driver behavior while cruising is
quite difficult, since there are many actions they could take.
\trbcite{anderson2014not} and \trbcite{henao2018impact} report some
drivers pull over while others circle in place or drive over to areas they deem
lucrative. Ridesourcing companies use dynamic pricing to balance their
vehicle supply with demand, partly from incentivizing their drivers to move to
high-demand areas through these higher prices \cite{gurley2014dynamic,
ubervideo}. Dynamic pricing will heavily affect cruising behaviour, but details
of their implementation and effectiveness are not publicly disclosed.
Meanwhile, it is extremely difficult to quantify ridesourcing drivers
commuting, since they may have their ridesourcing driving app turned off, and
may also incorporate travel they would had done independent of their
ridesourcing work.

In order to estimate deadheading, then, we make the simplifying assumption that
drivers immediately pull over after dropping off their previous passenger, and
once matched with a new passenger drive over to their pick-up via the shortest
travel-time route. We then can route en-route travel with the same algorithm
used to route in-service trips. This ensures we have a conservative estimate
for VKT during deadheading. We also do not consider the additional time
required for the ridesourcing company to match drivers and passengers, or the
time between drivers arriving at a passenger pick-up point and the start of the
trip, as these cannot be effectively estimated from the trip records.

To connect trips together into sequences, a process we refer to as "trip
linking", we adopt the methodology of \trbcite{vazifeh2018addressing} and
\trbcite{hanna2016minimum}. Both cast the problem of assigning drivers to trips
as finding a solution on a bipartite graph of feasible connections between the
two groups. Feasible connections are found by calculating travel times between
driver positions and trip pick-up points, and keeping those that are smaller
than some limit $\delta$. In particular, \citeauthor{vazifeh2018addressing}
forgo explicitly modeling vehicles by finding feasible connections between trip
drop-offs and subsequent trip pick-ups by checking if the en-route travel time
between them is shorter than both the time between drop-off and pick-up as well
as $\delta$. They then select a set of feasible connections such that each
drop-off is connected to at most one pick-up. They interpret sequences of
connected trips -- *"paths"* -- as sequences of trips serviced by an individual
driver. Because every path (including ones with only one trip) must be serviced
by a driver, the size of the vehicle fleet is an outcome of their model and
does not need to be specified. Moreover, while only en-route time is utilized
to determine feasibility, the time between drop-off and pick-up must be equal
to both the en-route *and* cruising times, so this methodology also outputs a
cruising time estimate.

We adopt \citeauthor{vazifeh2018addressing}'s notation and methodology. In
particular, we implement their "batch" methodology, which breaks $V$ into
sub-graphs representing short periods of time $t_\mathrm{batch}$:

1.  **Generate a dataset of feasible links:** we first converted trip records
    into a set of feasible connections from trip drop-offs to pick-ups
    over a 24 hour period. Feasible connections were found by binning drop-off
    points into five-minute intervals. For each drop-off, up to 30 of the
    closest pick-up points of trips beginning within the subsequent
    $20\,\mathrm{min}$ and $5\,\mathrm{km}$ are found (values
    chosen to make the calculation computationally tractable on our
    database system). The set of all drop-offs were then routed to the set of
    all pick-ups using the trip routing procedure from above. All routes
    that take longer to travel than the time difference between the
    drop-off and pick-up were discarded. The remaining routes represent
    feasible links between drop-offs and pick-ups, with a maximum en-route
    travel time $\delta \approx 20\,\mathrm{min}$.

2.  **Transform the feasible links into a graph $V(N, E)$:** the feasible links
    were then transformed into a directed acyclic graph $V(N, E)$ where nodes
    $N = \{n\}$ represent trips and edges $E = \{e\}$ represent the feasible
    connections, whose weights are the en-route travel times from Step 1. We
    define a path $P$ in $V(N, E)$ to be a sequence of edges that connect a
    sequence of nodes together such that no node has more than two adjacent
    edges belonging to the path; these represent the trips taken over a
    driver's work period. There may be zero-size $P$ that correspond to single
    unconnected trips. A set of paths $\{P\}$ where every node is included, but
    a node is only associated with one (possibly zero-size) path, is known as a
    (node-disjoint) *path cover*. It represents the trip sequences serviced by
    a population of drivers over the course of the day. Alongside $V(N,
    E)$, we initialized a **solution graph** $S(N, \emptyset)$, which has the
    same nodes as $V$, but no edges. This stores the path cover.

3.  **Link sections of $V$ in order of time:** we broke the day up into
    consecutive time bins each of width $t_\mathrm{batch}$, and, in time-order,
    perform the following for each bin:

    a.  **Create a subgraph $V_b$,** which consists of a set of trip $\{n\}_b$
        with pick-up times between $t$ and $t + t_\mathrm{batch}$, and all
        previous trips $\{n\}_{lb}$ that *have feasible links* to those in
        ${n}_\mathrm{s}$.  $\{n\}_{lb}$ trips may have drop-off times earlier
        than $t$.

    b.  **Transform $V_b$ into a bipartite graph:** following
        \trbcite{boesch1977covering}, we converted $V_b$ into a bipartite graph
        $\hat{V}_b$ by splitting each node $n$ into the trip drop-off $n^d$
        and pick-up $n^o$, then mapping the edges of $V_b$ onto these new
        nodes such that an edge connecting $n_i$ and $n_j$ in $V_b$ connects
        $n^d_i$ and $n^o_j$ in $\hat{V}_b$. Finding a path cover in $V_b$ is
        equivalent to finding a matching-- a subset of edges such that each
        node has only one adjacent edge -- in $\hat{V}_b$
        \cite{vazifeh2018addressing, boesch1977covering}.

    c.  **Find a matching for the bipartite graph:** we then used one of several
        algorithms to determine a matching within $\hat{V}_b$. These are detailed
        below. Once a matching was found, it was converted back into a path cover
        in $V_b$.

    d.  **Transfer the path cover onto $S$, and prune $V$:** the edges of $V_b$
        were transferred to $S$. Nodes with new outgoing edges in $S$ had their
        outgoing edges in $V$ removed, so that these nodes are not included in
        future subgraphs.

4.  **Determine volumes on streets:** once solution $S$ was complete, we
    converted the path cover back to a set of en-route trips and corresponding
    volumes on streets.

\noindent The matching algorithms we tested are:

-   **Maximum cardinality matching**: find a bipartite graph matching with as
    many edges as possible. This is equivalent to determining the minimum
    number of drivers required to service all trips within a time bin
    \cite{vazifeh2018addressing}. Our implementation uses the bipartite maximum
    matching function from `networkx` \cite{networkx}.

-   **Minimum weight maximum cardinality matching**: unlike the above
    algorithm, which does not take edge weights into account, this produces a
    maximum cardinality matching whose network weights are minimized.
    Effectively, this algorithm first minimizes the number of drivers, then
    optimizes their trip assignments to minimize the total en-route time.
    We implemented this as a minimum flow assignment problem using Google
    OR-Tools \cite{ortools}.

-   **Greedy matching**: connect each pick-up with the available drop-off with
    the shortest en-route time, handling the pick-ups in order of time.
    Drop-offs that are connected to pick-ups are no longer available to be
    connected with future pick-ups. This is a simplified version of Uber's
    driver-passenger matching algorithm \cite{hanna2016minimum, ubervideo}.
    Since trips are linked individually by order of pick-up time, a solution
    was calculated on the entire graph $V$, rather than through batching.

\noindent Our code for generating feasible links is available in
`bdit_triprouter`, while the code for trip linking is available at
[https://github.com/CityofToronto/bdit_triplinker](https://github.com/CityofToronto/bdit_triplinker).

Since trip linking is a highly simplified model of how drivers are connected
with passengers using limited data, it cannot be used to reconstruct the exact
service history of individual drivers. Our aim is instead to produce a set of
trip linkages that, in the aggregate, resembles real-life en-route
deadheading.

### Trip Linking Calibration {#sec:triplinkingcalibration}

We calibrate trip linking by selecting the combination of matching algorithm
and parameters that best reproduces the distribution of passenger wait times in
the trip records on October 20, 2016. The two tunable parameters are $\delta$
and (except for greedy matching) $t_\mathrm{batch}$. We used a Bayesian
hyperparameter optimizer to tune these for each of the matching algorithms,
using the Jensen-Shannon divergence \cite{lin1991divergence} between the
recorded and trip linking distributions of passenger wait times as an
objective function. Distributions from the optimally calibrated algorithms are
compared with the reported distribution in Figure [-@fig:waittime].

![Recorded distribution of passenger wait times on October 20, 2016, compared
with ones calculated from trip linking using different matching algorithms.
\label{fig:waittime}](source/figures/trb_waittime.pdf){width=100% }

For both maximum cardinality and greedy matching, we found the optimal $\delta$
to be as large as possible ($\approx20\,\mathrm{min}$, as mentioned in the
methodology). For maximum cardinality, the optimal $t_\mathrm{batch}$ is as
small as possible ($1\,\mathrm{min}$, as timestamps after April 2017 are at
best accurate to the minute). Interestingly, the minimum weight maximum
cardinality matching produced a distribution of wait times offset by
$\sim1.5\,\mathrm{min}$ from the reported distribution regardless of the tuning
parameter values. Between the three matching algorithms, maximum
cardinality produced a distribution closest to the recorded one, and so was
selected to produce our final results in Figure [-@fig:volfraction]. Since no
wait time data was available for September 13, we use the same parameters as
for October 20.

<!--- Changed the heading hierarchy here --->

## Testing and Validating the Volume Estimation Process

### Validating Trip Routing

Trip routing was validated by comparing routed distance with distance in the
ridesourcing trip records.

<!--- Negative outliers are much more important than positive ones; see
21 - TRB Paper Calculations --->

For October 20, 2016, the fractional difference between recorded and
routed distance is $-8\% \pm 17\%$. Both these values change by $\lesssim4\%$
if only trips greater than the median distance, trips within downtown Toronto,
or trips during peak commuting hours (7:00 - 10:00 a.m. and 4:00 - 7:00 p.m.),
are considered. The discrepancy can partly be explained by the lack of turn
restrictions, and partly by routing not capturing real-world complications like
queuing to turn at intersections, or circling to find an appropriate curbside
location to drop-off a passenger. The standard deviation is also inflated from
$\sim6\%$ of trips where the fractional difference is greater than $-33\%$.
Some of these appear to be tours of errands returning to their origin.

To reduce the fractional difference between linked and recorded results, we
aggregated to the Toronto neighbourhood level ($\sim 2\;\mathrm{km}$ across).
The fractional difference between recorded and routed aggregate VKT within
different neighbourhoods is $-7 \pm 2$ ($-6 \pm 4$ for morning
commuting hours and $-8 \pm 4$ for afternoon commuting).

### Validating Trip Linking

Trip linking was validated by comparing features of the generated results with
reported values from the ridesourcing companies.

#### *Number of Unique Drivers per Hour --*

A subset of ridesourcing companies provided the number of unique drivers per
hour for a set of 39 days from December 2017 - March 2019. An ordinary least
squares regression of the number of active drivers versus the number of
trips gave: <!---No space to get proper TeX formatting--->
$$N_\mathrm{Drivers} = 0.475 N_\mathrm{Trips} + 199.1$$ {#eq:nvehfit}

\noindent (adjusted $R^2$ = 0.962; RMS deviation $= 274.7$). This is equivalent
to about two trips per driver per hour, though it does not account for drivers
working for multiple ridesourcing companies and therefore slightly
overestimates the number of drivers required to service trips from all
companies in an hour.

![The number of trips per hour on September 13, 2018 and the number of
unique drivers per hour servicing the trips as estimated by a best fit to the
empirical data (Equation [-@eq:nvehfit]) and trip linking using the maximum
cardinality matching algorithm.
\label{fig:tripsperhour}](source/figures/trb_activedrivers.pdf){width=100% }

In Figure [-@fig:tripsperhour], we show the number of trips per hour on September
13, 2018, and compare the number of unique drivers predicted by Equation 
[-@eq:nvehfit] and by trip linking. Trip linking reproduces well the two-humped
shape of the best fit curve, but on average predicts $\sim10\%$ fewer drivers
per hour, which in the evening peak is a deficit of $\sim500 - 800$ drivers.
The trip linking driver number estimate for October 20, 2016 is also several
hundred fewer drivers than the best fit one, but since there were only half as
many trips on October 20 as there were on September 13, the fractional deficit
is $\sim25\%$.

#### *Deadheading as a Fraction of Total Activity --*

A subset of ridesourcing companies also provided the fraction of their
fleetwide aggregate VKT spent deadheading, reporting that $55\%$ of total VKT
is for in-service driving, $35-40\%$ is cruising, and $5-10\%$ en-route
driving. This means for each kilometer driven in-service, drivers typically
travel an additional $0.6 - 0.7$ kilometers cruising, and $0.1 - 0.2$
kilometers en-route to their next trip.

The ratio of aggregate en-route to in-service VKT from maximum cardinality trip
linking is $0.15$ for both October 20, 2016 and September 13, 2018, consistent
with the ridesourcing companies' records. However, the records show that
deadheading is dominated by cruising, and while trip linking does not calculate
a cruising VKT, we can estimate it by assuming the ratio of aggregate cruising
to in-service time is roughly the same as the ratio of distances. The
time ratios are sensitive to linking algorithm choice, and for September
13, 2018 range from $0.16$ for maximum cardinality to only $0.09$ for greedy
matching. Regardless of algorithm, though, the ratio is always far lower
than reported by the ridesourcing companies. Note that it is unclear whether
they includes drivers making trips unrelated to ridesourcing while keeping
their ridesourcing app open, which would inflate their cruising fraction.

## Assessing the Volume Estimation Process {#sec:assessment}

Given that we did not have to specify anything about the size or behavior of
the ridesourcing driver population, it is remarkable that trip linking is able
to approximate both the passenger wait time distribution (Figure 
[-@fig:waittime]) and number of drivers per hour (Figure [-@fig:tripsperhour]).
That said, all combinations of linking algorithms and parameters underestimate
the median passenger wait time by at least $20\,\mathrm{sec}$, and the number
of drivers by at least $10\%$. Moreover, it grossly underestimates the time
vehicles spend cruising. All these point to trip linking significantly
underestimating deadheading time and VKT. We therefore caution that our volumes
on streets estimates are conservative.

It is possible that some of the assumptions underlying trip linking lead to
unrealistic minimization of deadheading -- most notably, the minimum
weight maximum cardinality algorithm leads to a significant underestimate of
the passenger wait time (Figure [-@fig:waittime]). One way of more realistically
modelling ridesourcing inefficiencies would be to treat drivers as
agents that stop working after a set time, or after a particularly long trip.
Currently there is no maximum length of time for a work period, and $10\%$ of
periods from October 10, 2016 are longer than $4.6\,\mathrm{hrs}$. Another
possibility is that we need to explicitly model cruising behaviour -- perhaps
circling or driving to another neighbourhood during cruising lengthens its
duration. Implementing these features is a promising avenue for future work,
though more empirical data on ridesourcing driver behaviour is required.

One reason we believe agent-based modelling is promising is the work of
\trbcite{calderontrb}, who developed a prototype ridesourcing provision model
using the ridesourcing trip records. Their model is agent-based, and uses
recorded trip *request* times to link drivers and passengers, without requiring
that the driver also arrive at the recorded pick-up time. They also instantiate
drivers randomly throughout the city for deadheading before the first trip, and
use a different method to determine en-route travel times than we do. While our
method is better able to reproduce the recorded passenger wait time distribution,
their aggregate fractional VKT values -- $39\%$ cruising, $19\%$ en-route and $42\%$
in-service -- are much closer to trip record values, and they are able to
roughly reproduce wait times and drivers per hour using fewer trip record
attributes than we do. A comparative study will be required to understand which
differences between our models is most responsible for producing these
differences.

<!-- A comparative study
will be required to understand the effects of these differences; a comparison
also has the potential of producing a hybrid model with the best features from
both models.


It is difficult to discern why the two
models return such different results for cruising. 
 -->
<!-- The discrepancy between empirical and trip-linked number of unique
drivers per hour can be reduced by limiting the maximum time of a
driver work period \- this can be done probabilistically, as in \trbcite{calderontrb}
\- by randomly selecting drivers to end their driving after just one trip. This
simple agent modelling is equivalent to dividing the
driving population up into "incidental drivers" that drive for TNCs as
an extension of their own travels \cite{anderson2014not}, and part or full-time
shift drivers. \trbcite{anderson2014not} estimate $\sim15\%$ of San Francisco
TNC drivers are incidental, but also note that drivers fall along a continuum
between incidental and full-time workers, and may freely switch strategies.
\cite{} -->

<!-- These results suggest that trip linking more efficiently matches vehicles than
ridesourcing companies do in practice. We tested trip linking on feasible
link graphs where 10% of nodes were randomly "unlinked" -- have all outgoing
edges removed -- effectively reducing linking efficiency. While this led to a
$13\%$ increase in drivers per hour for October 20, reducing the fractional
deficit to $9\%$ from the best fit, the method is arbitrary, since there are
many different ways of decreasing linking efficiency including imposing driver
work period time limits or only unlinking long trips. Which strategy to use
cannot be constrained by available data, so we did not adopt unlinking trips
for our results. -->

<!-- Combining trip linking and the trip records allows us to estimate the
collective behavior of the ridesourcing driver population. For example, we find
the median work period on October 20 to be $1.4\,\mathrm{hr}$, but $\sim10\%$
of periods are longer than $4.6\,\mathrm{hr}$. While some full-time drivers do
report driving for more than 10 hours \cite{tocommittee}, their frequency is
unknown, and there are few known statistics on the population of ridesourcing
drivers. We thus save a full investigation of trip linking to determine driver
activity for future work. -->

<!-- Finally, while commute deadheading may be hard to quantify, it is also likely
to be a significant contributor to overall ridesourcing vehicle volume.
\citeauthor{anderson2014not} reports around three quarters of their sample of
20 ridesourcing drivers commute into San Francisco to drive. \citeauthor
{henao2018impact} reports end-of-shift commuting constituted $\sim15\%$ of
total VKT driven over the course of their study (they do not consider
commuting before the start-of-shift). A survey \cite{wspreport} conducted by
WSP Canada finds that more than half of ridesourcing drivers working in the
Greater Toronto Area live outside of Toronto, and nearly a third of driversthat
primarily operate in the Toronto & East York district live outside of Toronto.
Due to the difficulty of pinning down how much of a driver's commute is
specifically in service of driving for ridesourcing companies, the contribution
of commuting to deadheading might be solved by having drivers perform record
their travels as \citeauthor{henao2018impact} did.
 -->
