# Introduction

The growth of ridesourcing companies (alternatively ride-hailing companies or
transportation network companies (TNCs)) such as Uber and Lyft across North
American cities over the past decade has led to enormous and rapid changes in
travel behavior. In March of 2019, an average of 770,000 ridesourcing trips
were performed daily in New York City \cite{schneider2019dashboard} and
330,000 in Chicago \cite{chicago2019transportation}. Despite its prevalence,
how ridesourcing contributes to congestion, impacts other road users, interacts
with public transportation and affects transportation equity all remain topics
of active debate amongst researchers, city planners and policy-makers. This is
in part because details and data records of ridesourcing company operations are
generally kept private, forcing researchers to use novel means of collecting
them, such as scraping vehicle position data using APIs provided by the
companies (\trbcite{cooper2018profiling}) or even driving for the companies
themselves (\trbcite{henao2018impact}). Consequently, cases where companies
volunteer disaggregated trip data or submit it for regulation (eg.
\trbcite{rideaustin2017data}; companies in New York City \cite{nyctlc2019report})
make for unique opportunities to build comprehensive pictures of how they
operate within a city.

Uber first started offering its UberX service in Toronto, Canada, in September
2014. In response to growth in ridesourcing activity, in July 2016, the City of
Toronto amended the Vehicle-for-Hire (VFH) Bylaw \cite{vfhbylaw} that regulates
taxis and limousines to enable ridesourcing services to operate in the city by
September 2016. This bylaw requires ridesourcing companies to report individual
trip origin-destination (OD) data to the city. Lyft followed Uber into the
Toronto market at the end of 2017.

In 2018, the City undertook a comprehensive review of the bylaw, which included
a study on the transportation impacts of ridesourcing in Toronto. The study, a
collaboration between the Big Data Innovation Team within the City of Toronto's
Transportation Services Division and the University of Toronto Transportation
Research Institute (UTTRI), was published in June 2019 \citep{bdittoreport}.

This paper is a companion article to the study, and will summarize its most
important findings regarding congestion impact and curbside impacts. A critical
dataset for understanding localized congestion impacts was not provided to the
City by ridesourcing companies: the volume of vehicles on streets. We
therefore developed a novel process to estimate volumes by routing ridesourcing
passenger trips and modelling driver behaviour between those trips. Detailing
and validating this process will be the primary focus of the methodology.
Research conducted by UTTRI for this study are
detailed in other TRB submissions including a travel behavior survey
\cite{loatrb}, a study on transit alternatives to ridesourcing
\cite{wenting2019transitcharacteristics}, a regression on transit ridership
\cite{wenting2019transitcompetition}, and a ridesourcing service provision
model \cite{calderontrb}.

## Literature Review {#sec:literature_review}

Transportation agencies have historically operated with limited data on
ridesourcing companies' operations. The San Francisco County
Transportation Authority (SFCTA) performed their study by scraping
data from the APIs of Uber and Lyft, a technique which is unlikely to ever be
replicated because these companies have since restricted this access 
\cite{cooper2018profiling}. By comparing traffic speeds with a traffic model with
and without the presence of ridesourcing companies in San Francisco, they determined 
that 30% of the increase in congestion can be attributed to ridesourcing vehicles
\cite{Erhardteaau2670}. New York City has conducted multiple studies on the 
congestion impacts of ridesourcing: in 2016 finding that while ridesourcing 
operations contributed to congestion, other factors had contributed more to 
recent speed decreases in Manhattan \cite{nyc2016report}. In 2019, a study using video 
data collection found that ridesourcing companies make up 30% of vehicle miles
travelled (VMT) in downtown Manhattan \cite{nyctlc2019report}. Cities such as
New York City, Chicago, and Sao Paulo are now requiring detailed trip record
data. Our study is the first based on OD trip records provided to a City, and
the first to examine in detail such a long period of growth in ridesourcing trips. 
